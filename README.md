# Crush AP Learning Design

Public documentation for how Crush AP teaches. The site explains the Direct Instruction foundation, lesson presentation, examples and sequencing, correction, mastery, and cumulative review.

The content is intentionally one-way derived from the private Crush AP application repository. `docs-source-map.yml` maps each page to the sources allowed to govern it. Public copy is not a new pedagogy source of truth.

## Local development

```bash
mint dev
```

Validate the repository before opening a pull request:

```bash
ruby scripts/validate-docs.rb
mint broken-links
```

## Updating content

Human editors and the Mintlify automation follow the same rules:

1. Read the page entry in `docs-source-map.yml`.
2. Compare only the mapped authoritative sources.
3. Make the smallest public-facing change needed.
4. Cite the source repository commit in the pull request.
5. Wait for human review before merging semantic changes.

The standing Mintlify prompt and configuration notes live in `automation/`.
