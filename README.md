# Ingram Office Plugin

Claude Code plugin for the Ingram Office Obsidian vault.

## Setup

1. Install the plugin
2. Run `/setup-identity your-name /path/to/vault`
3. Restart your session — the hook will auto-pull and show your priorities

## What Happens Automatically

| Event | What runs | What it does |
|-------|-----------|-------------|
| Session start | `hooks/session-start` | Git pull, read inbox + P0/P1 tasks, inject context |
| Session end | `hooks/session-end` | Commit and push your changes |

No context wasted — hooks run as shell scripts and inject only a compact summary.

## Commands

| Command | When to use |
|---------|-------------|
| `/check-in` | Full team standup (everyone's activity, blockers, deadlines) |
| `/track-work` | Log activity mid-session, update task status, assign work |
| `/aggregate` | Rebuild project status + kanban boards (scheduled daily or manual) |
| `/retro` | Generate weekly retrospective (scheduled weekly or manual) |
| `/setup-identity` | Configure your name and vault path (run once) |

## Architecture

```
hooks/
  session-start    — deterministic: pull, inbox, priorities → context injection
  session-end      — deterministic: commit + push on stop
commands/
  *.md             — thin slash-command wrappers → invoke skills
skills/
  check-in/        — full standup report (read-only)
  track-work/      — mid-session logging + task assignment
  daily-aggregation/ — git-diff incremental project rebuild + log rotation
  weekly-retrospective/ — 7-day velocity + trends report
```

- Identity stored in `~/.ingram-office/identity.json`
- Run state + logs in `~/.ingram-office/` (never committed)
- Hooks handle git sync deterministically — skills focus on content
