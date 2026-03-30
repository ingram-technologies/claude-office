# Ingram Office Plugin

Claude Code plugin for the Ingram Office Obsidian vault — a central documentation hub.

Task tracking happens in GitHub. This plugin handles doc sync, change visibility, and coordination flags.

## Setup

1. Install the plugin
2. Run `/setup-identity your-name /path/to/vault`
3. Restart your session

## What Happens Automatically

| Event | Hook | What it does |
|-------|------|-------------|
| Session start | `session-start` | Git pull, show open todos + recent change count |
| Session end | `session-end` | Commit and push your doc changes |

## Commands

| Command | What it does |
|---------|-------------|
| `/check-in` | What changed, who needs to coordinate, standup topics |
| `/aggregate` | Rebuild project status views, flag coordination needs (daily scheduled) |
| `/retro` | Weekly retrospective from git history (weekly scheduled) |
| `/setup-identity` | Configure your name and vault path (run once) |

## Architecture

- **Git history is the source of truth** — no activity logs or task tracking in the vault
- `task.md` is your personal todo list, not a team-managed task system
- Hooks handle sync deterministically (shell scripts, no context waste)
- Skills focus on analysis: coordination flags, change summaries, standup topics
- All state/logs in `~/.ingram-office/` (never committed)
