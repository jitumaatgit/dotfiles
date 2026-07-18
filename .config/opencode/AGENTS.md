
- ALWAYS USE PARALLEL TOOLS WHEN APPLICABLE.
- The computer is Windows and it is ephermeral; It restores to defualt state after restarts/crashes. I want as much
tracked in git as possible because of this limitation.
- i use a bootstrap script from my public dotfiles to restore it to a state i like:
  - `https://github.com/jitumaatgit/dotfiles/main/setup.ps1`
  - I also have other repos that are private for other things, like secrets, and notes, that i clone into the computer
  when I need them.
- the terminal is using git/bash in windows. so `/c/` is preferable to `C://`
- Prefer automation: execute requested actions without confirmation unless blocked by missing info or safety/irreversibility.

## Compaction → handoff-first gate

Before calling the `compress` (DCP context-pruning) tool, you MUST first ask the user in chat whether they want to `/handoff` first. Do not compress in the same turn as the offer. If the user accepts, invoke the `handoff` skill via the `skill` tool, then compress. If the user declines, compress. The DCP prompt overrides under `~/.config/opencode/dcp-prompts/overrides/` are authoritative for this rule; this note is a backup.

## Style Guide

### General Principles

- Keep things in one function unless composable or reusable
- Avoid `try`/`catch` where possible
- Avoid using the `any` type
- Prefer single word variable names where possible
- Rely on type inference when possible; avoid explicit type annotations or interfaces unless necessary for exports or clarity
- Prefer functional array methods (flatMap, filter, map) over for loops; use type guards on filter to maintain type inference downstream

### Naming

Prefer single word names for variables and functions. Only use multiple words if necessary.

### Naming Enforcement (Read This)

THIS RULE IS MANDATORY FOR AGENT WRITTEN CODE.

- Use single word names by default for new locals, params, and helper functions.
- Multi-word names are allowed only when a single word would be unclear or ambiguous.
- Do not introduce new camelCase compounds when a short single-word alternative is clear.
- Before finishing edits, review touched lines and shorten newly introduced identifiers where possible.
- Good short names to prefer: `pid`, `cfg`, `err`, `opts`, `dir`, `root`, `child`, `state`, `timeout`.
- Examples to avoid unless truly required: `inputPID`, `existingClient`, `connectTimeout`, `workerPath`.

```ts
// Good
const foo = 1
function journal(dir: string) {}

// Bad
const fooBar = 1
function prepareJournal(dir: string) {}
```

Reduce total variable count by inlining when a value is only used once.

```ts
// Good
const journal = await Bun.file(path.join(dir, "journal.json")).json()

// Bad
const journalPath = path.join(dir, "journal.json")
const journal = await Bun.file(journalPath).json()
```

### Destructuring

Avoid unnecessary destructuring. Use dot notation to preserve context.

```ts
// Good
obj.a
obj.b

// Bad
const { a, b } = obj
```

### Variables

Prefer `const` over `let`. Use ternaries or early returns instead of reassignment.

```ts
// Good
const foo = condition ? 1 : 2

// Bad
let foo
if (condition) foo = 1
else foo = 2
```

### Control Flow

Avoid `else` statements. Prefer early returns.

```ts
// Good
function foo() {
  if (condition) return 1
  return 2
}

// Bad
function foo() {
  if (condition) return 1
  else return 2
}
```

### Schema Definitions (Drizzle)

Use snake_case for field names so column names don't need to be redefined as strings.

```ts
// Good
const table = sqliteTable("session", {
  id: text().primaryKey(),
  project_id: text().notNull(),
  created_at: integer().notNull(),
})

// Bad
const table = sqliteTable("session", {
  id: text("id").primaryKey(),
  projectID: text("project_id").notNull(),
  createdAt: integer("created_at").notNull(),
})
```

## Testing

- Avoid mocks as much as possible
- Test actual implementation, do not duplicate logic into tests

## ADB on Windows (Git Bash)

- ADB path: install via `scoop install adb` (preferred) or `winget install Google.PlatformTools` — not on PATH by default, must prepend or export. On ephemeral machines the winget path often does not exist; scoop is more reliable.
- `MSYS_NO_PATHCONV=1` is **mandatory** for `adb pull/push` in Git Bash — without it, MSYS converts `/sdcard/` paths to Windows paths and ADB fails with "No such file or directory"
- `adb shell uiautomator dump` writes to device, then `adb pull` to local. Dump path like `/data/local/tmp/` is more reliable than `/sdcard/` (avoids permission issues)
- `uiautomator dump` only captures the **visible viewport** and **truncates long TextViews** (~3000 chars). To capture scrollable content: rapid multi-swipe (`input swipe x1 y1 x2 y2 duration`) + dump per viewport, then deduplicate by content hash
- UI dump XML is one massive line — parse with Python `xml.etree.ElementTree`, iterate nodes, extract `text`/`content-desc`/`bounds` attributes
- `run-as <package>` only works for debuggable apps — Tasker (`net.dinglisch.android.taskerm`) is not debuggable, so internal data requires root or content providers
- Tasker AI Chat activity: `net.dinglisch.android.taskerm/com.joaomgcd.oldtaskercompat.aigenerator.ui.ActivityAIChat` — conversation data stored in app-private storage, no accessible content provider, no export feature
- `adb shell content query --projection` uses colons (`address:body:date`), not commas. `--sort` does NOT support `DESC` — only ascending sort by column name works.
- `date` field in SMS content provider (`content://sms`) is epoch **milliseconds**, not seconds. Divide by 1000 before passing to `datetime.fromtimestamp()`.
- `content://sms/inbox` stores addresses with `+1` country code (e.g., `+17865431612`); `content://sms/sent` stores recipient without `+1` prefix (e.g., `7865431612`). The same number can appear differently in inbox vs sent queries.
- `content query --where` only supports exact `=` matches. `LIKE` and other SQL operators throw `Unsupported argument` error.
- `adb shell content query --where` with `+` prefix fails: the `+` in phone numbers gets URL-mangled by the shell. To query for a number with `+1` prefix, query by `date` instead, or use an un-prefixed variant.
- `content://telephony/carriers` and `content://telephony/siminfo/` require phone/system UID and fail with `SecurityException` via ADB — can't query SIM phone numbers this way.
- `getprop gsm.sim.operator.alpha` shows carrier names (e.g., Access Wireless, cricket) but not actual phone numbers. The `.numeric` codes map to carriers but require external lookup to identify which SIM is which.

## Termux on Android

- Fresh Termux installs need `termux-setup-storage` run once to create `~/storage/shared/` symlink. Without it, `cp` to `/sdcard/` fails and ADB can't pull files from Termux.
- `am start -n com.termux/.app.TermuxActivity` brings Termux to foreground (needed before `input text` commands)
- `input text` in adb shell: spaces must be `%s`, and you need `input keyevent ENTER` after. Not reliable for long strings.
- `adb push` to `/data/data/com.termux/files/home/` fails (Permission denied); `run-as com.termux` also fails (Termux is not debuggable). Only Termux itself can write to its private home. Deploy via `git pull` within Termux, not adb push.
- `input text` shell metacharacters (`>`, `&`, `|`) get interpreted by the outer `adb shell` interpreter, not sent as keystrokes. Send tokens individually with explicit `keyevent 62` (space), or write a short script to `/sdcard/` first.
- `pkg install file` to get the `file` command for binary identification (not installed by default)

## Tasker XML Import

- "Bad packed data format" error → loose `<Task>` elements without `<Project>` wrapper. Always wrap in Project.
- "Missing event type" error → profile has invalid/placeholder event code. Use a real built-in event code, then reconfigure in Tasker UI after import.
- Plugin events (ntfy, etc.) cannot be represented in standard Tasker XML. Use placeholder event code, import, then manually reconfigure.
- `Notify` (code 523) `arg12`-`arg15` are Intent-based action buttons, NOT task name references. Use Tasker HTTP Server + Command System for HTTP-based button callbacks.
- **Variable Search Replace (code 598) stores WHOLE matches, not capture groups**: `%array1` contains the full text matched by the search pattern, not the first capture group. Tasker discards capture groups immediately. Use lookbehind assertions (`(?<=prefix)pattern`) instead of capture groups when extracting substrings.

## OpenCode Server Auth

- Adding a `"server": { "port": <N> }` block to `opencode.json` starts an HTTP server — the TUI terminal connects through it. `OPENCODE_SERVER_PASSWORD` must be set at server startup (OpenCode Desktop exports it for its sidecar; child shells inherit it). Username defaults to `opencode`; override with `OPENCODE_SERVER_USERNAME`.
- `opencode run` (incl. the `occ` function in `~/.bash_aliases`) authenticates fine WITH `OPENCODE_SERVER_PASSWORD` set against a running server — the spawned run client sends the inherited password. Do NOT unset it; unsetting causes "Unauthorized: header authorization was missing".
- The old "Session not found" bug #24747 advice to `unset OPENCODE_SERVER_PASSWORD` is OBSOLETE as of 1.17.18. It predated the server block being added; with a server running, unsetting breaks auth. The `unset` workaround was removed from `occ`, `ralph/afk.sh`, and `ralph/once.sh` on 2026-07-15.
- `--command` takes a slash-command NAME (e.g. `commit`), NOT shell. `opencode run --command "git status"` errors with "Unexpected server error" because `"git status"` isn't a command — that is a misuse, not an auth issue.

## OpenCode Provider Auth

- `opencode run` auth bug: `Unauthorized: Header of type 'authorization' was missing` → auth.json not loaded for provider API calls (issue #36181). Error appears **after** command completes, when main model tries to respond. Fix: set `<PROVIDER>_API_KEY` env vars (e.g. `NVIDIA_API_KEY`, `OPENCODE_API_KEY`). See `~/notes/docs/20-resources/opencode-auth-bug.md`.

## OpenCode File Tools (Write/Edit)

- The `write`/`edit` tools require Windows-style paths (`C:\Users\...`), NOT Git Bash paths (`/c/Users/...`). Git Bash paths report "Wrote file successfully" but the file silently does not land where bash can see it. This contradicts the shell convention (`/c/` preferable in the terminal) — the file tools are the exception.
- Skills installed via `npx skills add` mid-session are NOT discoverable by the `skill` tool until opencode restarts (skills load at startup). Workaround: read `~/.agents/skills/<name>/SKILL.md` directly with the `read` tool.

## Type Checking

## Agent skills

### Issue tracker

GitHub issues on `jitumaatgit/dotfiles`. See `docs/agents/issue-tracker.md`.

### Triage labels

Five canonical roles using default names (`needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`). See `docs/agents/triage-labels.md`.

### Domain docs

Single-context repo. `CONTEXT.md` at root. See `docs/agents/domain.md`.

### Upstream skills changelog (mattpocock/skills v1.1, Jul 2026)

- `/to-prd` → `/to-spec` — name matches what we actually build
- `/to-issues` → `/to-tickets` — unified, not GitHub-biased
- `/wayfinder` — break plans into agent-sized chunks with blocking relationships
- `/code-review` — uses Martin Fowler's refactoring smells
- `/research` + `/prototype` — supporting skills for the Wayfinder workflow
- Grilling fixes — no self-grilling, no skipping to implementation
- Complete lifecycle flow: Grill → Spec → Tickets → Implement → Code Review

Reinstall: `npx skills@latest add mattpocock/skills -g -y -s <name> ...` (skip `obsidian-vault` and `handoff` to protect user edits; delete orphans `to-issues`, `to-prd`, `decision-mapping`, `review`).

