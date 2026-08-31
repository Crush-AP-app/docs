# Daily Crush AP documentation sync

Keep the public Crush AP Learning Design documentation aligned with approved source changes.

Repositories:

- Source: `/Users/kanishkjain/Documents/code/Crush AP/crush-ap-v2`
- Documentation: `/Users/kanishkjain/Documents/code/Crush AP/crush-ap-docs`

On each run:

1. Fetch `origin/main` in both repositories without changing the source repository's working branch or files.
2. Read the documentation repository's `AGENTS.md` and `docs-source-map.yml`.
3. Read the `source_commit` values in the mapped public MDX pages and `images/app/manifest.yml`. Compare mapped source files and screenshot source paths between the oldest recorded commit and current `origin/main` of `Crush-AP-app/crush-ap-physics-v2`.
4. If none of the mapped sources changed, report no action needed and stop.
5. If mapped sources changed, read the changed sources and every other source mapped to the affected pages. Read `docs/pedagogy/authority.md` before making semantic judgments.
6. Follow the authority order exactly: direct human rulings and recorded correction history; Connecting Math Concepts and Engelmann sources; current pedagogy stage documents and executing contracts; shipped lessons as evidence only.
7. Never infer pedagogy from generated lesson JSON or from this public documentation. Never edit the private source repository or its pedagogy files.
8. If authoritative sources conflict and the hierarchy does not resolve the conflict, make no semantic change for that claim. Report the conflict and stop for human direction.
9. Update only existing pages mapped to changed sources. Do not add, delete, rename, or reorganize topics. Make the smallest accurate public change and preserve accurate wording.
10. Distinguish current product behavior from aspirations, archived behavior, rollout notes, and planned work. Do not describe unshipped behavior as current.
11. Preserve the public voice: concrete language for educators, school partners, and interested parents; no emojis; no em dashes; no private student data, credentials, or unnecessary proprietary detail. Paraphrase third-party source material.
12. Set `source_commit` on each affected page to the full current source commit, including pages reviewed and found to require no wording change. This records that the page was checked against that source state.
13. If an affected screenshot source path changed, compare the current account-free preview route with the existing image. Recapture only when the visible state changed. Use synthetic state, exclude development controls and all personal data, update the manifest fields and checksum, and preserve its existing caption and alt text unless the visible meaning changed. A generated lesson remains evidence only, never pedagogy authority.
14. Run `CRUSH_AP_SOURCE_ROOT="/Users/kanishkjain/Documents/code/Crush AP/crush-ap-v2" ruby scripts/validate-docs.rb` and the available Mintlify broken-link check.
15. If content changed, create or reuse one branch named `codex/automated-docs-sync` in the documentation repository. Commit and push the validated changes, then open or update one pull request into `main`. Never merge it.
16. The pull request must list the source commit, source paths read, pages checked, semantic changes, screenshot changes, validation results, and any uncertainty. Avoid stylistic churn and duplicate pull requests.

Never purchase a plan, change Mintlify billing, change repository permissions, or enable automerge.
