# Outcome

Keep the existing Crush AP Learning Design pages faithful to the newest merged changes in `Crush-AP-app/crush-ap-physics-v2`. Propose the smallest accurate documentation update in a pull request. If no mapped public claim changed, make no changes.

# Procedure

1. Read `AGENTS.md` and `docs-source-map.yml` in the documentation repository before editing.
2. Identify which source files changed in the merged pull request that triggered this run.
3. Select only existing pages whose `sources` list contains a changed file. Do not add, delete, rename, or reorganize topics.
4. Read every mapped source for each selected page, starting with `docs/pedagogy/authority.md` whenever it is mapped or relevant to a conflict.
5. Apply this authority order exactly:
   1. direct human rulings and recorded correction history;
   2. Connecting Math Concepts and Engelmann source material;
   3. current pedagogy stage documents and executing contracts;
   4. shipped lessons as evidence only.
6. Never infer pedagogy from generated lesson JSON, a single shipped lesson, comments in an unrelated file, or this public documentation.
7. If mapped sources conflict, do not choose a winner unless the authority order resolves it. Leave the page unchanged and report the conflict, source paths, and passages in the run summary.
8. Distinguish current product behavior from aspirations, rollout notes, archived behavior, and planned work. Do not describe an unshipped feature as current.
9. Preserve the existing audience and voice: educators, school partners, and interested parents; concrete language; active voice; no emojis; no em dashes; no internal credentials, private student data, or unnecessary proprietary details.
10. Paraphrase third-party source material. Do not copy long passages or expose source PDFs in the public repository.
11. Change only claims affected by the source update. Preserve accurate wording and page structure.
12. Set `source_commit` in each changed page's frontmatter to the full source repository commit SHA used for the update.
13. Update `docs-source-map.yml` only when a human-approved page path or mapping changed in the triggering pull request. Otherwise leave it unchanged.
14. Run `ruby scripts/validate-docs.rb` and the available Mintlify broken-link check.

# Pull request requirements

Use the title `docs: align learning design with <short source change>`.

The pull request body must include:

- the triggering source pull request and full source commit;
- every source path read;
- every public page changed;
- a short before-and-after description of each semantic claim;
- validation results;
- any conflict, uncertainty, or rollout caveat that needs human review.

Never merge the pull request. Never enable automerge. A run with no material public change should end with no action needed.
