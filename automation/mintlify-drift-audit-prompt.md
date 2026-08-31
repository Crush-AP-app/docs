# Outcome

Audit the existing Crush AP Learning Design site against its mapped authoritative sources. Open one focused pull request only when a public claim is stale, contradicted, or materially incomplete. Otherwise make no changes.

# Procedure

1. Read `AGENTS.md`, `docs-source-map.yml`, and `automation/mintlify-update-prompt.md`.
2. Compare each page with only the source files mapped to it.
3. Prioritize high-consequence drift: authority changes, correction behavior, presentation law, mastery accounting, review scheduling, and features described as shipped when they are not.
4. Follow the authority order and all boundaries in `automation/mintlify-update-prompt.md`.
5. Do not redesign the information architecture or invent a new documentation topic.
6. Group related corrections into one pull request. Do not open a pull request for stylistic churn.
7. Set the `source_commit` frontmatter on each changed page to the full source repository commit used for the audit.
8. Run `ruby scripts/validate-docs.rb` and the available Mintlify broken-link check.

The pull request must list the source commit, source paths, changed pages, semantic differences, and validation. Keep the update in `Modify and wait for review` mode and never merge it.
