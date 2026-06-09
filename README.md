# Ingram Office Plugin

Claude Code plugin for the Ingram Office Obsidian vault — a central documentation hub for the team.

Task tracking happens in GitHub. This plugin handles doc sync, change visibility, and coordination.

---

## The Mental Model

> Read this before touching a single command. It takes 2 minutes and makes everything else obvious.

claude-office is not a standalone app. It is a **layer that lives inside your Claude Code sessions** — invisible when things are working, powerful when you look at the output.

There are exactly 4 things to hold in your head.

![Stage 0 diagram](img/stage0.png)

### 1 — The Hub

One shared git repo. Everyone on the team clones it. Obsidian is just the viewer on top of it — nothing lives there that you type manually.

Inside the vault, two kinds of files matter:

- `team/<you>/activity/` — your per-repo session logs
- `projects/*/status.md` — synthesized project state

Think of it as **mission control**.

### 2 — Your Repos

They stay exactly where they are. You keep working normally in Claude Code. Nothing moves, nothing gets restructured.

The plugin lurk your sessions from the outside. Your repos are the **spokes**; the vault is the **hub**.

```
vault/                  ← the hub (its own repo, shared)
  team/nicolas/
  projects/my-app/
my-app/                 ← a spoke (your normal repo, untouched)
other-project/          ← another spoke
```

### 3 — The Hooks

Two shell scripts fire automatically at the edges of every session. You never trigger them manually.

| Hook | When | What it does |
|---|---|---|
| `session-start` | When you open Claude Code | Git pulls the vault, injects your identity + open todos |
| `session-end` | When you close Claude Code | Parses the conversation transcript, writes your activity to `team/<you>/activity/` |

They are deterministic shell scripts — no AI, no surprises, no context waste. They only inject metadata (counts, not raw file content) to prevent prompt injection.

> **One important detail:** hooks activate only after you restart your session post-install.

### 4 — The Value Loop

Every day, this cycle runs and builds the shared team memory:

```
activity logs  →  /claude-office:aggregate  →  status.md files  →  /claude-office:check-in  →  YOU (next session)
   (amber)         (glue cmd)       (in the vault)     (on-demand)     (briefed & ready)
```

- **`/claude-office:aggregate`** — parses all activity logs, writes per-person summaries into each project's `status.md`. Run daily.
- **`/claude-office:check-in`** — reads your subsection from each project's status, hands you back a personalized briefing.
- **`/claude-office:retro`** — weekly synthesis across all projects, for strategic perspective.

The longer the team uses it, the richer the context becomes.

---

*Now you have the map. Every command in the Setup section below has a logical home in this model.*

---

## Setup

The plugin lives in your **project repos** (the spokes). The vault is set up once and reused everywhere.

**Step 1 — Install the plugin** (once per machine)

```bash
/plugin marketplace add ingram-technologies/claude-office
/plugin install claude-office@ingram-technologies
```

We recommend activating it per repository rather than account-wide.

**Step 2 — Initialize a project repo** (once per spoke)

```bash
/claude-office:init your-name /path/to/vault
```

Clones the vault template if it doesn't exist, sets up Obsidian config, saves your identity. Pass `--create-repo` to create the vault GitHub repo via `gh` CLI.

**Step 3 — Fill out your profile**

```bash
/claude-office:setup-identity your-name /path/to/vault
```

Run it bare (`/claude-office:setup-identity`) to reconfigure at any time.

**Step 4 — Restart your session**

Hooks activate on the next session start. From here, everything runs automatically.

> **Permission error on hooks?** Run `chmod +x ~/.claude/plugins/cache/ingram-technologies/claude-office/1.0.1/hooks/*` then restart.

**Step 5 — Orient yourself**

```bash
/claude-office:check-in
```

Gets you up to speed on all active projects. Run this at the start of any session.

> **First time?** Run through the [Level 1 dry-run](TUTORIAL_LEVEL_1.md) in a throwaway sandbox before pointing this at a real project. Takes 20 minutes and confirms the mental model by experience.

---

→ [Command reference](COMMANDS.md) — full list of commands, hooks, and local state  
→ [Architecture & design decisions](ARCHITECTURE.md) — how it works under the hood  
→ [Integrations](INTEGRATIONS.md) — pairing with structural or fact-memory tools (graphify, supermemory, and a rubric for others)
