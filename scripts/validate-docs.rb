#!/usr/bin/env ruby

require "json"
require "yaml"

ROOT = File.expand_path("..", __dir__)
CONFIG_PATH = File.join(ROOT, "docs.json")
SOURCE_MAP_PATH = File.join(ROOT, "docs-source-map.yml")

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
    %w[title description source_commit].each do |key|
      errors << "page frontmatter is missing #{key}: #{page}" if metadata[key].to_s.strip.empty?
    end
  rescue StandardError => error
    errors << "page frontmatter is invalid for #{page}: #{error.message}"
  end

  errors << "page contains an em dash: #{page}" if content.include?("—")
end

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

source_root = ENV["CRUSH_AP_SOURCE_ROOT"]
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
