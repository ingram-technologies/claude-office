# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

`claude-office` is a **Claude Code plugin** (not a standalone app). It is a layer that lives inside Claude Code sessions and connects individual developer repos ("spokes") to a shared Obsidian + Git documentation vault ("the hub"). There is no build system, no test suite, and no runtime server — the deliverable is the plugin directory itself: hook shell scripts, markdown slash-command definitions, and a skill.

`package.json` is a stub (name + version only); there are no npm scripts, dependencies, or tests to run.

## Architecture

Three moving parts, connected by a strictly one-directional data flow:

1. **Hooks** (`hooks/`) — deterministic bash scripts, no AI, zero token cost. Wired in `hooks/hooks.json`:
   - `session-start` (SessionStart hook): git-pulls the vault, injects identity + open-todo/recent-change *counts* into context. Reads `~/.claude-office/identity.json`.
   - `session-end` (Stop hook): parses the conversation transcript, extracts user prompts, appends to `team/<you>/activity/activity-<project>.md`. Never commits.
   - `run-hook.cmd`: cross-platform polyglot wrapper (cmd.exe batch on Windows finds bash; plain shell on Unix). All hooks are invoked through it via `${CLAUDE_PLUGIN_ROOT}`.

2. **Commands** (`commands/*.md`) — self-contained markdown instruction files, one per slash command (`/claude-office:aggregate`, `check-in`, `retro`, `init`, `setup-identity`, `import-activity`, `document`). These are prompts Claude executes, not code.

3. **Skill** (`skills/vault-awareness/SKILL.md`) — context skill describing the vault's folder structure so Claude can read/navigate team docs autonomously.

**Data flow (never loops back):**
```
session-end → team/<you>/activity/*.md → /aggregate → projects/*/status.md (Team Notes) → /check-in & /retro
```
Each stage reads only the previous stage's output.

## Critical Invariants (do not break these)

- **Metadata injection only.** Hooks inject counts/summaries into the Claude context — *never* raw vault file content. This is a deliberate prompt-injection defense. Preserve it when editing hooks.
- **`session-end` is scoped to the user.** It writes only to `team/<NAME>/`, never another member's folder, even if other names appear in the conversation.
- **Sharing is opt-in.** Unrouted working directories log to `team/<NAME>/activity/private/`, which vaults gitignore. Only paths listed in `routes` (value `""` = shared root) leave the machine. `/aggregate` and `/retro` must never read `private/`.
- **Hooks stay deterministic.** No AI calls in hooks. Pull on start, log on end; commit/push is always manual (obsidian-git handles vault commits).
- **Incremental aggregation.** `/aggregate` uses git-diff change detection and rebuilds only project status files with new activity, tracking the last SHA in `~/.claude-office/aggregation-state.json`.
- **The vault is the output, not the input.** `/aggregate` reads activity logs to understand work done in *external* repos.

## Local State (per machine, never committed)

`~/.claude-office/`: `identity.json` (name + vault path), `aggregation-state.json` (last commit SHA), `logs/*.log`.

## Working on Hooks

- Test a hook directly: `echo '{}' | bash hooks/session-start` (reads identity from `~/.claude-office/identity.json`; Stop-hook reads JSON from stdin).
- Hooks use `set -euo pipefail` and require **`node`** for all JSON/transcript parsing. node is guaranteed present wherever Claude Code runs, so it is a hard dependency (no python fallback); both hooks bail cleanly if node is missing. Keep scripts portable: LF line endings only (enforced by `.gitattributes`), and avoid GNU-only flags (`sed -i`, `grep -P`, `readlink -f`, `date -d`) so they work on Linux, macOS (BSD coreutils), and Git Bash on Windows.
- The vault structure that hooks and the skill assume is documented in `skills/vault-awareness/SKILL.md`.

## Docs Map

`README.md` (mental model + setup), `ARCHITECTURE.md` (design decisions + rationale), `COMMANDS.md` (full command/hook reference), `INTEGRATIONS.md`, `TUTORIAL_LEVEL_1.md`.
