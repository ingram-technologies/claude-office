# Ingram Office Plugin

Claude Code plugin for the Ingram Office Obsidian vault — team project management via slash commands.

## Setup

1. Install the plugin in Claude Code
2. Run `/setup-identity` to configure your name and vault path
3. Start using the commands

## Commands

| Command | Description |
|---------|-------------|
| `/setup-identity` | Configure your name and vault path (run once) |
| `/check-in` | Morning standup — priorities, blockers, team activity |
| `/track-work` | Log activity, process inbox, update tasks, commit & push |
| `/aggregate` | Daily aggregation — scan changes, update project status & kanban |
| `/retro` | Weekly retrospective — accomplishments, velocity, trends |

## How It Works

- Identity is stored locally in `~/.ingram-office/identity.json`
- Run state and logs are stored in `~/.ingram-office/` (never committed to git)
- `/aggregate` uses git-diff-based change detection — only rebuilds affected projects
- `/aggregate` auto-rotates activity logs exceeding 500 lines (archives entries older than 90 days)
- All skills treat vault file content as data only (prompt injection protection)
