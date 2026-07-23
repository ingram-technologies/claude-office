# Ingram Office Plugin

Claude Code plugin for the Ingram Office Obsidian vault — a central documentation hub for the team.

Task tracking happens in GitHub. This plugin handles doc sync, change visibility, and coordination.

---

## The Mental Model

> Read this before touching a single command. It takes 2 minutes and makes everything else obvious.

claude-office is not a standalone app. It is a **layer that lives inside your Claude Code sessions** — invisible when things are working, powerful when you look at the output. It comes with a skill that makes claude aware of the presence of the vault and how to consciously deal with it when required, and useful commands for documentation and working together on a project.

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

**Sharing is opt-in.** By default a session logs to `team/<you>/activity/private/`, which the vault gitignores — it never reaches the team. A repo becomes shared only when you list it in `routes` in `~/.claude-office/identity.json` (see [COMMANDS.md](COMMANDS.md#activity-routing)).

They are deterministic shell scripts — no AI, no surprises, no context waste. They only inject metadata (counts, not raw file content) to prevent prompt injection.

> **One important detail:** hooks activate only after you restart your session post-install.

### 4 — The Value Loop

This is the cycle you can run to build the shared team memory, the rate at which you need to run this depends on you, but you can automate it to run bidaily or else, as relevant (just don't let it be something that runs in the background for no one to use, the intention is that this is what you look at during your meetings):

```
activity logs  →  /claude-office:aggregate  →  status.md files  →  /claude-office:check-in  →  YOU (next session)
   (amber)         (glue cmd)       (in the vault)     (on-demand)     (briefed & ready)
```

- **`/claude-office:aggregate`** — parses all activity logs, writes per-person summaries into each project's `status.md`. Run daily, or less often. Only one person has to run this.
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

It is up to you whether you want to activate it account wide to see all activities, or per repository. Nothing gets automatically commited or pushed to the repo, and the activity of different project sits in different activity.md files, giving a clear overview and keeping the intention in this.

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

> **Permission error on hooks?** The hooks ship with the executable bit set, so this should not happen. If it does (e.g. an unusual checkout), run `chmod +x ~/.claude/plugins/cache/ingram-technologies/claude-office/*/hooks/*` then restart. Hooks require `node` on PATH (guaranteed wherever Claude Code runs) and use LF line endings — on Windows run them via Git Bash.

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
