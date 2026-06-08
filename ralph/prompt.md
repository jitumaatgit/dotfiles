# ISSUES

GitHub issues labelled `ready-for-agent` are provided at start of context. Parse them to understand the open work.

You've also been passed the last few commits. Review these to understand what work has been done.

If all `ready-for-agent` tasks are complete, output the phrase `NO MORE TASKS`.

# TASK SELECTION

Pick the next task. Prioritize tasks in this order:

1. Critical bugfixes
2. Development infrastructure

Getting development infrastructure like shell config and dev scripts ready is an important precursor to building features.

3. Tracer bullets for new features

Tracer bullets are small slices of functionality that go through all layers of the system, allowing you to test and validate your approach early.

4. Polish and quick wins
5. Refactors

# EXPLORATION

Explore the repo. Read AGENTS.md for critical context, conventions, and known pitfalls. Read CONTEXT.md for domain glossary.

Key repo facts:
- This is a Windows dotfiles/configuration repo, tracked in git for ephemeral machine recovery
- Shell: Git Bash (MINGW64), .bashrc is the main shell config
- Gitignore: `/*` deny-by-default — new root files/dirs need `!/name` entries
- Secrets: stored in `~/notes/` (private), sourced in `.bashrc`
- Bootstrap: `setup.ps1` restores all Scoop packages, fonts, AHK, nvim

# IMPLEMENTATION

Implement the task following the conventions in AGENTS.md.

# FEEDBACK LOOPS

Before committing:

- `shellcheck filename.sh` on any modified bash scripts (if available)
- `bash -n filename.sh` for syntax validation (always available)
- Verify changes don't break `bash -i -c 'exit'` (interactive shell starts cleanly)

# COMMIT

Make a git commit. The commit message must:

1. Prefix with scope: `tui:`, `ci:`, `docs:`, `wip:`, `fix:`, `refactor:`
2. Describe WHY from end-user perspective, not WHAT changed
3. Include files changed

# THE ISSUE

If the task is complete, comment on the GitHub issue with a summary of changes and close it:

```bash
gh issue comment <number> --body "### Done\n\n<summary of changes>\n\nCommit: <hash>"
gh issue close <number>
```

If the task is not complete, comment on the issue with what was done and what remains.

# FINAL RULES

ONLY WORK ON A SINGLE TASK.
