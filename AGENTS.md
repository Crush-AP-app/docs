# Crush AP documentation instructions

This is the public explanation layer for Crush AP learning design. It is derived from the private application repository and never becomes a pedagogy authority.

## Source hierarchy

1. Direct human rulings and recorded correction history in the application repository.
2. Connecting Math Concepts and Engelmann source material.
3. Current pedagogy stage documents and executing contracts.
4. Shipped lessons as evidence only.

Read `docs-source-map.yml` before changing any public page. Use only the mapped source files for claims on that page. If sources conflict, stop and flag the conflict. Never infer policy from generated lesson JSON.

## Editorial rules

- Write for educators, school partners, and interested parents.
- Explain the principle, then show how the product implements it.
- Prefer concrete language over educational jargon.
- Distinguish a current product behavior from an aspiration.
- Do not expose private student data, internal credentials, unpublished lesson content, or proprietary implementation details that are not needed to explain the learning design.
- Do not copy long passages from third-party sources. Paraphrase and cite them on the Sources page.
- Do not use emojis or em dashes.

## Change policy

- Semantic changes require a pull request and human review.
- Keep each page's `source_commit` frontmatter current when an automation changes its claims.
- Update `docs-source-map.yml` when adding, renaming, or deleting a public page.
- Run `ruby scripts/validate-docs.rb` and `mint broken-links` before merging.
