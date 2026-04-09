---
description: "First-time setup — configure your identity, fill out your profile, and learn how the plugin works. Usage: /setup-identity <your-name> <vault-path>"
argument-hint: "<your-name> <vault-path>"
---

This is the onboarding command. It sets up identity, fills out the user's profile, and explains the plugin.

**Example:** `/setup-identity alex C:/Users/alex/Documents/ingram-vault`

**Key principle:** Write to profile.md progressively — after each section is collected, write it immediately. Don't batch everything at the end. This way if the conversation is interrupted, partial progress is saved.

## Step 1: Identity

If arguments are provided, parse as `<name>` and `<vault-path>`. Otherwise ask:
- "What's your name?" (must match their folder name in `/team/<name>/`, lowercase)
- "Where is your Ingram Office vault?" (absolute path, e.g., `C:/Users/alex/Documents/ingram-vault`)

**The vault is a separate GitHub repository** (not part of this plugin). It's an Obsidian vault where the team keeps docs, project statuses, and coordination files. It should already contain `CLAUDE.md`, a `/team/` folder, and a `/team/_new_user/` template. If you don't have the vault yet, clone it first and then come back.

Create `~/.claude-office/` and `~/.claude-office/logs/` if they don't exist.

Write `~/.claude-office/identity.json`:
```json
{
  "name": "<name>",
  "vault": "<vault-path>"
}
```

Verify the vault path exists and contains `CLAUDE.md`. Verify `/team/<name>/` exists. If not, offer to create it from `/team/_new_user/` — copy the folder, replace all `<PUT YOUR NAME HERE>` placeholders with their name.

Make sure the hooks are allowed with chmod if on mac/linux.

## Step 2: Fill Out Profile (Progressive)

Read `/team/<name>/profile.md`. Walk the user through each section below. **After each section, write the answers into profile.md immediately** before moving to the next section.

**Auto-detect what you can** — don't ask questions you can answer from the environment:
- OS: `uname -s` / `$OS` / `$OSTYPE`
- Shell: `$SHELL` or `$0`
- Node version, Python version if available
- MCP servers: read `~/.claude/settings.json` if accessible

### 2a. Role & About
Ask:
- What's your role? (e.g., Security Engineer, Full-Stack Developer, DevOps)
- Fun fact — something about themselves (hobby, hot take, superpower)

→ **Write to profile.md** (Role, Joined date, Fun fact)

### 2b. Environment
Auto-detect OS, shell, and MCP servers. Ask about:
- Device (laptop model, desktop)
- IDEs and editors (VS Code, JetBrains, Cursor, Neovim, etc.)
- AI coding tools (Claude Code, Copilot, Cursor, etc.)
- Browser and extensions
- Package managers

→ **Write to profile.md** (full Environment section)

### 2c. Security
Read the security section template from the user's `profile.md` (copied from `_new_user/`). The template defines what fields need filling — don't hardcode questions here, just walk through whatever the template asks for.

Mention: "If you'd rather fill out the security section manually later, just say 'skip' and you can edit `team/<name>/profile.md` directly anytime."

If they choose to fill it now, walk through each field in the template and write answers as you go.

→ **Write to profile.md** (Security section — or mark as skipped)

### 2d. Contact & Project
- How to reach them (Slack, email)
- Which project are they primarily working on? (list available projects from `/projects/`)

→ **Write to profile.md** (Contact + note their main project)

## Step 3: Explain the Plugin

After setup is complete, give the user a brief orientation:

> **You're all set!** Here's how the Ingram Office plugin works:
>
> **Automatic (you don't need to do anything):**
> - When you start a session, the plugin pulls the latest vault changes and shows you a quick summary
> - When your session ends, it logs what docs you changed to your activity.md and pushes everything
>
> **Commands you can run:**
> - `/check-in` — Start of day briefing. Shows what you were last working on, your priorities across projects, who you need to coordinate with, and your personal todos
> - `/aggregate` — Rebuilds project status views with per-person notes. Runs daily on a schedule, but you can trigger it manually
> - `/retro` — Generates a weekly retrospective from git history
>
> **How coordination works:**
> `/aggregate` analyzes git history and writes notes into each project's status.md — things like what you should focus on next and who you need to sync with. When you run `/check-in`, it reads those notes so you get a personalized briefing.
>
> **Your files:**
> - `team/<name>/profile.md` — your bio (what we just filled out)
> - `team/<name>/tasks.md` — your personal todo list (only you manage this)
> - `team/<name>/activity.md` — automatic log of your doc changes (plugin writes this)
>
> **Task tracking happens in GitHub** — the vault is for documentation and coordination.
>
> Restart your session for the hooks to activate, then try `/check-in`.

## Step 4: Commit

Stage and commit the user's new/updated folder:
```bash
git add team/<name>/
git commit -m "[<name>] onboarding — profile setup"
git push
```
