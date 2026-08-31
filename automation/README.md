# Documentation automation setup

## Recommended: Codex scheduled task

Mintlify's native automations require its $450 per month Pro plan. Crush AP does not need that plan for documentation maintenance.

Use the Codex scheduled task in `automation/codex-daily-prompt.md` instead. It checks the mapped sources once each weekday, opens or updates a review pull request only when public claims changed, and never merges. Mintlify remains the site host and deploys documentation after an approved pull request reaches `main`.

Requirements:

- the Mac is powered on with the ChatGPT desktop app running at the scheduled time;
- both repositories remain available at their current local paths;
- GitHub CLI authentication remains valid.

## Optional: Mintlify-native setup

Mintlify automations require a Pro or Enterprise plan. The GitHub App must be installed on both repositories:

- Documentation: `Crush-AP-app/docs`
- Source context and trigger: `Crush-AP-app/crush-ap-physics-v2`

## Automation 1: source-change editor

- Name: `Update learning design from product changes`
- Trigger: `Code change`
- Source repository: `Crush-AP-app/crush-ap-physics-v2`
- Context repository: `Crush-AP-app/crush-ap-physics-v2`
- Update mode: `Modify and wait for review`
- Prompt: paste `automation/mintlify-update-prompt.md`

This automation runs after a pull request merges in the source repository. It updates only pages mapped to changed source files.

## Automation 2: weekly drift audit

- Name: `Audit learning design documentation drift`
- Trigger: `Custom schedule`, every Monday
- Context repository: `Crush-AP-app/crush-ap-physics-v2`
- Update mode: `Modify and wait for review`
- Prompt: paste `automation/mintlify-drift-audit-prompt.md`

The second automation catches missed or cross-cutting changes. It should produce no action when the public pages remain faithful.

## Operating policy

- Keep both automations review-only.
- Do not grant ruleset bypass or enable automatic merge.
- Do not upgrade Mintlify solely for this workflow. The Codex scheduled task covers it.
- Review source conflicts with the pedagogy owner.
- Close low-value proposals instead of weakening the prompt.
- Rate-limit the drift audit to weekly. An earlier autonomous proposal loop in the product repository was disabled after it produced spam pull requests.
