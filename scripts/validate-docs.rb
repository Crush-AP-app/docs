#!/usr/bin/env ruby

require "json"
require "yaml"
require "digest"
require "open3"

ROOT = File.expand_path("..", __dir__)
CONFIG_PATH = File.join(ROOT, "docs.json")
SOURCE_MAP_PATH = File.join(ROOT, "docs-source-map.yml")
SCREENSHOT_MANIFEST_PATH = File.join(ROOT, "images", "app", "manifest.yml")

errors = []

begin
  config = JSON.parse(File.read(CONFIG_PATH))
rescue StandardError => error
  warn "docs.json is invalid: #{error.message}"
  exit 1
end

begin
  source_map = YAML.safe_load(File.read(SOURCE_MAP_PATH), aliases: false)
rescue StandardError => error
  warn "docs-source-map.yml is invalid: #{error.message}"
  exit 1
end

def navigation_pages(config)
  tabs = config.dig("navigation", "tabs") || []
  tabs.flat_map do |tab|
    (tab["groups"] || []).flat_map { |group| group["pages"] || [] }
  end
end

nav_pages = navigation_pages(config)
map_entries = source_map.fetch("pages", [])
mapped_pages = map_entries.map { |entry| entry["page"] }
page_metadata = {}

nav_pages.each do |page|
  path = File.join(ROOT, "#{page}.mdx")
  errors << "navigation page is missing: #{page}.mdx" unless File.file?(path)
  errors << "navigation page is not mapped: #{page}.mdx" unless mapped_pages.include?("#{page}.mdx")
end

map_entries.each do |entry|
  page = entry["page"]
  sources = entry["sources"]
  path = File.join(ROOT, page.to_s)

  errors << "mapped page is missing: #{page}" unless File.file?(path)
  errors << "mapped page is not in navigation: #{page}" unless nav_pages.include?(page.to_s.sub(/\.mdx\z/, ""))
  errors << "mapped page has no sources: #{page}" unless sources.is_a?(Array) && !sources.empty?

  Array(sources).each do |source|
    if source.include?("..") || source.start_with?("/")
      errors << "source path must be repository-relative: #{source}"
    end
    if source.include?("/lessons/") && source.end_with?("lesson.json")
      errors << "generated lesson JSON cannot be an authority source: #{source}"
    end
  end

  next unless File.file?(path)

  content = File.read(path)
  frontmatter = content.match(/\A---\s*\n(.*?)\n---\s*\n/m)&.captures&.first
  unless frontmatter
    errors << "page has no YAML frontmatter: #{page}"
    next
  end

  begin
    metadata = YAML.safe_load(frontmatter, aliases: false)
    page_metadata[page] = metadata
    %w[title description source_commit].each do |key|
      errors << "page frontmatter is missing #{key}: #{page}" if metadata[key].to_s.strip.empty?
    end
  rescue StandardError => error
    errors << "page frontmatter is invalid for #{page}: #{error.message}"
  end

  errors << "page contains an em dash: #{page}" if content.include?("—")
end

begin
  screenshot_manifest = YAML.safe_load(File.read(SCREENSHOT_MANIFEST_PATH), aliases: false)
  raise "manifest root must be a map" unless screenshot_manifest.is_a?(Hash)
rescue StandardError => error
  errors << "images/app/manifest.yml is invalid or missing: #{error.message}"
  screenshot_manifest = { "screenshots" => [] }
end

screenshot_entries = screenshot_manifest.fetch("screenshots", [])
unless screenshot_entries.is_a?(Array)
  errors << "screenshot manifest screenshots must be a list"
  screenshot_entries = []
end
manifest_source_commit = screenshot_manifest.dig("capture_policy", "source_commit").to_s
manifest_paths = screenshot_entries.map { |entry| entry["file"].to_s }

errors << "screenshot manifest has no screenshots" if screenshot_entries.empty?
errors << "screenshot manifest contains duplicate files" unless manifest_paths.uniq.length == manifest_paths.length

screenshot_entries.each do |entry|
  %w[file route alt caption source_commit captured_at privacy_status sha256].each do |key|
    errors << "screenshot manifest entry is missing #{key}: #{entry["file"] || "unknown"}" if entry[key].to_s.strip.empty?
  end
  unless entry["source_paths"].is_a?(Array) && !entry["source_paths"].empty?
    errors << "screenshot manifest entry has no source paths: #{entry["file"] || "unknown"}"
  end

  file = entry["file"].to_s
  path = File.join(ROOT, file)
  if file.include?("..") || file.start_with?("/") || !file.start_with?("images/app/")
    errors << "screenshot path must stay under images/app: #{file}"
    next
  end

  errors << "screenshot must be a PNG: #{file}" unless File.extname(file).downcase == ".png"
  errors << "screenshot route must be site-relative: #{file}" unless entry["route"].to_s.start_with?("/")
  errors << "screenshot privacy review has not passed: #{file}" unless entry["privacy_status"] == "passed"
  errors << "screenshot source commit is invalid: #{file}" unless entry["source_commit"].to_s.match?(/\A[0-9a-f]{40}\z/)
  if !manifest_source_commit.empty? && entry["source_commit"].to_s != manifest_source_commit
    errors << "screenshot source commit differs from capture policy: #{file}"
  end

  unless File.file?(path)
    errors << "screenshot file is missing: #{file}"
    next
  end

  actual_sha256 = Digest::SHA256.file(path).hexdigest
  errors << "screenshot checksum is stale: #{file}" unless actual_sha256 == entry["sha256"].to_s
end

image_files = Dir.glob(File.join(ROOT, "images", "app", "*.png")).map { |path| path.delete_prefix("#{ROOT}/") }
(image_files - manifest_paths).each { |file| errors << "screenshot file is not in the manifest: #{file}" }

referenced_screenshots = []
source_root = ENV["CRUSH_AP_SOURCE_ROOT"]
map_entries.each do |entry|
  page = entry["page"].to_s
  path = File.join(ROOT, page)
  next unless File.file?(path)

  content = File.read(path)
  content.scan(/src=["']\/(images\/app\/[^"']+)["']/).flatten.each do |file|
    referenced_screenshots << file
    manifest_entry = screenshot_entries.find { |candidate| candidate["file"] == file }
    unless manifest_entry
      errors << "page references a screenshot missing from the manifest: #{page}: #{file}"
      next
    end

    page_commit = page_metadata.dig(page, "source_commit").to_s
    screenshot_commit = manifest_entry["source_commit"].to_s
    source_paths = Array(manifest_entry["source_paths"])
    if source_root && !source_root.empty?
      source_paths.each do |source_path|
        errors << "screenshot source path is missing: #{file}: #{source_path}" unless File.file?(File.join(source_root, source_path))
      end
      if page_commit.match?(/\A[0-9a-f]{40}\z/) && screenshot_commit != page_commit
        _stdout, stderr, status = Open3.capture3(
          "git", "-C", source_root, "diff", "--quiet", screenshot_commit, page_commit, "--", *source_paths
        )
        if status.exitstatus == 1
          errors << "screenshot source changed since capture: #{page}: #{file}"
        elsif !status.success?
          errors << "could not compare screenshot source commits: #{file}: #{stderr.strip}"
        end
      end
    end
    errors << "screenshot alt text differs from manifest: #{page}: #{file}" unless content.include?(manifest_entry["alt"].to_s)
    errors << "screenshot caption differs from manifest: #{page}: #{file}" unless content.include?(manifest_entry["caption"].to_s)
  end
end

(manifest_paths - referenced_screenshots).each { |file| errors << "manifest screenshot is not used by a mapped page: #{file}" }

map_entries.each do |entry|
  page = entry["page"]
  path = File.join(ROOT, page.to_s)
  next unless File.file?(path)

  File.read(path).scan(/href=["']\/(?!\/)([^"'#?]+)["']/).flatten.each do |target|
    normalized = target.sub(%r{/$}, "")
    normalized = "index" if normalized.empty?
    target_path = File.join(ROOT, "#{normalized}.mdx")
    errors << "broken internal link in #{page}: /#{target}" unless File.file?(target_path)
  end
end

if source_root && !source_root.empty?
  map_entries.flat_map { |entry| entry["sources"] || [] }.uniq.each do |source|
    errors << "mapped source is missing: #{source}" unless File.file?(File.join(source_root, source))
  end
end

if errors.empty?
  puts "Documentation validation passed: #{nav_pages.length} pages, #{map_entries.length} source-map entries."
  exit 0
end

warn errors.uniq.map { |error| "- #{error}" }.join("\n")
exit 1
