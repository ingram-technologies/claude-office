# Command Reference

Full reference for all claude-office commands, hooks, and local state.

← [Back to README](README.md)

---

## Commands

| Command | When to use | What it does |
|---|---|---|
| `/claude-office:init` | First time, per repo | Clones the vault template, sets up Obsidian config, saves your identity, optionally creates a GitHub repo |
| `/claude-office:setup-identity` | After `/claude-office:init`, or to reconfigure | Fills out your profile in the vault |
| `/claude-office:check-in` | Start of any session | Reads your `@name` subsection from each project's Team Notes — recaps last work, shows todos, stamps your profile |
| `/claude-office:aggregate` | Daily (or on-demand) | Parses all `team/*/activity/**/*.md` logs + git diffs, writes per-person Team Notes into each project's `status.md` |
| `/claude-office:retro` | Weekly | Cross-project synthesis — team velocity, collaboration health, strategic observations |
| `/claude-office:import-activity` | When onboarding mid-project | Selectively imports past activity into `team/<you>/activity/`. Run bare to see options. |

---

## Hooks

Hooks are shell scripts — deterministic, no AI, no context waste. They inject metadata only (counts, never raw file content) to prevent prompt injection.

| Hook | Trigger | Actions |
|---|---|---|
| `session-start` | Opening Claude Code | Git pull on vault · Inject identity into context · Inject open todo count · Alert on recent vault changes |
| `session-end` | Closing Claude Code | Parse conversation transcript · Extract user prompts · Write to `team/<you>/activity/activity-<project>.md` · No auto-commit |

**Note:** session-end only writes to `team/<you>/`, never to other team members' folders.

---

## Data Flow

```
session-end (automatic)
  writes: team/<you>/activity/activity.md — session logs from work in external repos
      │
      ▼
/claude-office:aggregate (daily, scheduled)
  reads:  team/*/activity/**/*.md logs (primary) + git history + project docs
  writes: ## Team Notes with per-person subsections into each project's status.md
      │
      ▼
/claude-office:check-in (per person, on demand)
  reads:  your @name subsection from each project's Team Notes
  writes: "Last checked in" line in your profile.md
  output: personalized briefing — last work, priorities, coordination, todos
      │
      ▼
/claude-office:retro (weekly, scheduled)
  reads:  aggregated project status files + activity patterns + git stats
  writes: weekly report with cross-project team analysis
```

**Aggregate vs retro:** `/claude-office:aggregate` is the operational data pipeline (daily, per-project). `/claude-office:retro` is the strategic synthesis (weekly, cross-project). They are separate by design.

---

## Local State

Stored in `~/.claude-office/` on each machine. Never committed to git.

| File | Purpose |
|---|---|
| `identity.json` | Your name, vault path, and optional activity `routes` (see below) |
| `aggregation-state.json` | Last commit SHA for incremental diff detection |
| `logs/daily-aggregation.log` | Run history for debugging `/claude-office:aggregate` |
| `logs/retro.log` | Run history for debugging `/claude-office:retro` |

### Activity Routing

**Sharing is opt-in.** A session whose working directory matches no route logs to
`team/<you>/activity/private/activity-<project>.md`, and vault `.gitignore` keeps
`team/*/activity/private/` out of git. Nothing you work on reaches the team until you say so.

To share a repo, route it with a `routes` map in `~/.claude-office/identity.json`:

```json
{
  "name": "Alexandre",
  "vault": "/home/alexandertg/Documents/GitHub/sandbox-office-vault",
  "routes": {
    "~/Documents/GitHub/claude-office": "",
    "~/Documents/GitHub": "work",
    "~/Documents/GitHub/loci": "work/loci"
  }
}
```

- Keys are working-directory prefixes (`~` expands). **Longest match wins**, so subfolders inherit their
  parent's route unless a deeper key overrides it — `~/Documents/GitHub/loci/api` lands in `work/loci/`.
- Values are subfolders under `team/<you>/activity/`; they are created on demand and cannot escape it.
- `""` means the shared activity root, `team/<you>/activity/activity-<project>.md`.
- No match → `private/`, which is gitignored.
- The filename always follows the working directory name.

**Why subfolders:** any subfolder can be gitignored, so you can keep more than one tier — e.g. a `work/`
folder shared with the team and `private/` that never leaves your machine.
