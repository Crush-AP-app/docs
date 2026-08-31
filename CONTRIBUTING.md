# Contribute to Crush AP Learning Design

Documentation changes are welcome through pull requests.

Before editing a page, read its entry in `docs-source-map.yml`. Each entry identifies the private source files that govern its claims. If you cannot access those sources, limit your change to spelling, formatting, or an issue report.

## Review requirements

- Keep claims faithful to the mapped sources.
- Flag conflicts instead of choosing a convenient source.
- Paraphrase third-party material and retain attribution.
- Do not use generated lessons as policy evidence.
- Run `ruby scripts/validate-docs.rb` and `mint broken-links`.
- Request human review for every semantic change.

## App screenshots

Screenshots are evidence of the shipped experience, not pedagogy authority. Capture them only from the source app's account-free local preview routes with synthetic state.

1. Start a clean source worktree at the source commit recorded by the affected documentation pages.
2. Use `/lesson-preview/<slug>?surface=student` for lessons and `/course-home-preview` for the synthetic course path.
3. Crop development-only controls and confirm that no account menu, email address, student response, or other personal data is visible.
4. Save the PNG under `images/app/` and add its route, alt text, caption, source paths, source commit, capture date, privacy status, and SHA-256 checksum to `images/app/manifest.yml`.
5. Embed it with a Mintlify `Frame` and an `img` whose caption and alt text exactly match the manifest.
6. Run validation with `CRUSH_AP_SOURCE_ROOT` set. The validator detects missing images, checksum drift, privacy status, unused files, mismatched copy, and source changes that make a capture stale.
