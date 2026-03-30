---
description: "First-time setup — configure identity, fill out your profile, and learn how the plugin works"
argument-hint: "[your-name] [vault-path]"
---

This is the onboarding command. It sets up identity, fills out the user's profile, and explains the plugin.

## Step 1: Identity

If arguments are provided, parse as `<name>` and `<vault-path>`. Otherwise ask:
- "What's your name?" (must match their folder name in `/team/<name>/`, lowercase)
- "Where is your Ingram Office vault?" (absolute path, e.g., `C:/Users/alex/Documents/ingram obsidian vault`)

Create `~/.ingram-office/` and `~/.ingram-office/logs/` if they don't exist.

Write `~/.ingram-office/identity.json`:
```json
{
  "name": "<name>",
  "vault": "<vault-path>"
}
```

Verify the vault path exists and contains `CLAUDE.md`. Verify `/team/<name>/` exists. If not, offer to create it from `/team/_new_user/` — copy the folder, replace all `<PUT YOUR NAME HERE>` placeholders with their name.

## Step 2: Fill Out Profile

Read `/team/<name>/profile.md`. Walk the user through filling out the empty fields in a natural conversation. Ask about:

1. **Role** — What's your role? (e.g., Security Engineer, Full-Stack Developer, DevOps)
2. **About / Fun fact** — Something about themselves
3. **Environment**:
   - OS and version (detect automatically if possible via `uname` or environment variables)
   - Device (laptop model, desktop)
   - Shell (detect from `$SHELL` or current shell)
   - IDEs and editors they use (VS Code, JetBrains, Cursor, Neovim, etc.)
   - AI coding tools (Claude Code, Copilot, Cursor, etc.)
   - MCP servers they have configured (check `~/.claude/settings.json` if accessible)
   - Browser and extensions
   - Package managers
4. **Security**:
   - Disk encryption (BitLocker, FileVault)
   - Password manager
   - MFA enabled
   - Pre-commit hooks
   - SSH key type
5. **Contact** — How to reach them (Slack, email)
6. **Main project** — Which project are they primarily working on? (list the available projects from `/projects/`)

Write all gathered info into `profile.md`, filling in the placeholder fields.

**Auto-detect what you can** — don't ask questions you can answer from the environment:
- OS: `uname -s` / `$OS` / `$OSTYPE`
- Shell: `$SHELL` or `$0`
- Node version, Python version if available
- Check `~/.claude/settings.json` for MCP servers

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
> - `team/<name>/task.md` — your personal todo list (only you manage this)
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
