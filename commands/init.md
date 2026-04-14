---
description: "Initialize a new Claude Office vault — clone the template, set up Obsidian config, and save identity. Usage: /init <your-name> <destination-path>"
argument-hint: "<your-name> <destination-path>"
---

This is the first-time setup command for teams who don't have the vault yet.

**Example:** `/init alex C:/Users/alex/Documents/ingram-vault`

## Step 1: Parse Arguments

If arguments are provided, parse as `<name>` and `<destination-path>`. Otherwise ask:
- "What's your name?"
- "Where do you want to clone the vault?" (absolute path, e.g., `C:/Users/alex/Documents/ingram-vault`)

## Step 2: Clone the Vault

Clone the template vault and remove the origin so the repo is standalone:

```bash
git clone https://github.com/ingram-technologies/claude-office-vault "<destination-path>"
git -C "<destination-path>" remote remove origin
```

If the clone fails, stop and report the error clearly.

## Step 3: Run the Obsidian Sync Script

This sets up the `.obsidian/` config from the bundled template:

- **Windows:** `powershell -ExecutionPolicy Bypass -File "<destination-path>/sync-obsidian.ps1"`
- **macOS/Linux:** `bash "<destination-path>/sync-obsidian.sh"`

Detect the OS from the environment (`$OS`, `uname`, etc.) to pick the right script.

If the script fails, warn the user but don't stop — they can run it manually later.

## Step 4: Save Identity

Create `~/.claude-office/` and `~/.claude-office/logs/` if they don't exist.

Write `~/.claude-office/identity.json`:
```json
{
  "name": "<name>",
  "vault": "<destination-path>"
}
```

## Step 5: Create GitHub Repo (Optional)

Ask the user if they want to publish the vault to GitHub now:

> "Do you want to create a GitHub repo for this vault? I can set it up with `gh` CLI. (yes / no, I'll do it later)"

If yes, ask for a repo name (suggest `<org>-vault` or similar) and whether it should be public or private. Then:

```bash
gh repo create "<repo-name>" --private --source="<destination-path>" --push
```

If `gh` is not installed or the command fails, tell them to run it manually when ready.

If no, remind them:

> When you're ready: `gh repo create <name> --private --source="<destination-path>" --push`

## Step 6: Done

Tell the user:

> **You're set up!** Open the vault in Obsidian: File → Open Vault → select `<destination-path>`.
>
> Next steps:
> - Run `/setup-identity` to fill out your profile and get a walkthrough of the plugin
> - Run `/check-in` in some sessions to get updates relevant to you from the vault
