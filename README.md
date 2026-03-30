# Ingram Office Plugin

Claude Code plugin for the Ingram Office Obsidian vault — a central documentation hub for the team.

Task tracking happens in GitHub. This plugin handles doc sync, change visibility, and coordination.

## Setup

1. Install the plugin in Claude Code
2. Run `/setup-identity your-name /path/to/vault`
3. Restart your session — hooks activate automatically

## What Happens Automatically

| Event | Hook | What it does |
|-------|------|-------------|
| Session start | `session-start` | Git pull, inject identity + open todo count + recent change alerts |
| Session end | `session-end` | Commit and push your doc changes (your folder only) |

Hooks are shell scripts — deterministic, no context waste. They inject metadata only (counts, never raw file content) to prevent prompt injection.

## Commands

| Command | What it does |
|---------|-------------|
| `/check-in` | Resume your session — reads per-person notes from `/aggregate`, recaps last work, shows todos, stamps profile |
| `/aggregate` | Scan git diffs, write per-person Team Notes into each project's status.md, flag coordination needs (daily scheduled) |
| `/retro` | Weekly retrospective from git history — contributions, coordination, stalled areas (weekly scheduled) |
| `/setup-identity` | Configure your name and vault path (run once) |

## Architecture

```
hooks/
  session-start     — git pull, inject identity + counts (deterministic)
  session-end       — commit + push your folder only (deterministic)
commands/
  *.md              — slash commands (some invoke skills, some are self-contained)
skills/
  check-in/         — read aggregated notes, recap, todos, profile stamp
  daily-aggregation/ — git-diff scan, per-person project notes, coordination flags
```

### Data Flow

```
/aggregate (daily, scheduled)
  reads: git log + project status.md + kanban.md
  writes: ## Team Notes with per-person subsections into each project
      │
      ▼
/check-in (per person, on demand)
  reads: your @name subsection from each project's Team Notes
  outputs: personalized briefing (last work, priorities, coordination, todos)
  writes: "Last checked in" line in your profile.md
```

## Design Decisions

- **Git history is the source of truth** — no activity.md, no inbox.md, no separate tracking
- **Hooks for deterministic work** — pull/push happen as shell scripts, not LLM instructions
- **Metadata injection only** — hooks never inject raw file content into context (prompt injection prevention)
- **Writer/reader pattern** — aggregate writes notes, check-in reads them (no duplicate analysis)
- **Session-end scoped to user** — only commits `team/<you>/`, never other folders
- **Incremental aggregation** — git-diff change detection, only rebuilds affected projects
- **task.md is personal** — your own todo list, not a team-managed task system

## Local State

Stored in `~/.ingram-office/` (never committed to git):

| File | Purpose |
|------|---------|
| `identity.json` | Your name and vault path |
| `aggregation-state.json` | Last commit SHA for incremental diff detection |
| `logs/daily-aggregation.log` | Run history for debugging |
| `logs/retro.log` | Run history for debugging |
