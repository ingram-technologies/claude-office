# Ingram Office Plugin

Claude Code plugin for the Ingram Office Obsidian vault — a central documentation hub for the team.

Task tracking happens in GitHub. This plugin handles doc sync, change visibility, and coordination.

## Setup

1. To install the plugin in Claude Code, run `/plugin marketplace add ingram-technologies/claude-office` then `/plugin install ingram-technologies@claude-office` (we recommend activating it for specific repositories instead of account wide)
2. Fork the vault template from https://github.com/ingram-technologies/claude-office-vault (you probably want to make your repo private)
3. Run `/setup-identity your-name /path/to/vault` to do the one time setup of which team member you are and where the vault is located
4. Either run `/reload-plugins` or restart your session — hooks activate automatically and store what you do in activity.md when the plugin is active 
5. You can use `/check-in` to get context on your projects, and `/import-activity` to add past activity to the activity.md in a selective way
6. Use `/aggregate` for daily aggregation (works since the last time it ran) and `/retro` to update the documentation to match

## What Happens Automatically

| Event | Hook | What it does |
|-------|------|-------------|
| Session start | `session-start` | Git pull, inject identity + open todo count + recent change alerts |
| Session end | `session-end` | Log prompts + file changes to activity.md (no auto-commit) |

Hooks are shell scripts — deterministic, no context waste. They inject metadata only (counts, never raw file content) to prevent prompt injection.

## Commands

| Command | What it does |
|---------|-------------|
| `/check-in` | Resume your session — reads per-person notes from `/aggregate`, recaps last work, shows todos, stamps profile |
| `/aggregate` | Parse activity.md logs + git diffs, write per-person Team Notes into each project's status.md (daily scheduled) |
| `/retro` | Weekly cross-project synthesis — team velocity, collaboration health, strategic observations (weekly scheduled) |
| `/setup-identity` | Configure your name and vault path (run once) |
| `/import-activity` | Import previous activity on various projects, you can either enter the command without arguments to see your options or specify |

## Architecture

```
hooks/
  session-start     — git pull, inject identity + counts (deterministic)
  session-end       — parse transcript, log prompts + changes to activity.md (no auto-commit)
commands/
  *.md              — slash commands (self-contained instruction files)
```

### Data Flow

```
session-end (automatic)
  writes: team/<you>/activity.md — session logs from work in external repos
      │
      ▼
/aggregate (daily, scheduled)
  reads: activity.md logs (primary) + git history + project docs
  writes: ## Team Notes with per-person subsections into each project
      │
      ▼
/check-in (per person, on demand)
  reads: your @name subsection from each project's Team Notes
  outputs: personalized briefing (last work, priorities, coordination, todos)
  writes: "Last checked in" line in your profile.md
      │
      ▼
/retro (weekly, scheduled)
  reads: aggregated project status files + activity.md patterns + git stats
  writes: weekly report with cross-project team analysis
```

## Design Decisions

- **Activity log captures intent** — session-end extracts user prompts from the conversation transcript into activity.md
- **Activity.md is the primary lens** — aggregate parses session logs to see work in external repos, not just vault edits
- **Hooks for deterministic work** — pull on start, log on end, commit/push is manual
- **Metadata injection only** — hooks never inject raw file content into context (prompt injection prevention)
- **Writer/reader chain** — session-end → activity.md → aggregate → project files → check-in / retro
- **Aggregate vs retro** — aggregate is the operational data pipeline (daily, per-project), retro is the strategic synthesis (weekly, cross-project)
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
