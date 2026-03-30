---
description: "Configure your Ingram Office identity (name and vault path)"
argument-hint: "[your-name] [vault-path]"
---

Set up the user's Ingram Office identity so all skills know who they are and where the vault is.

## Process

1. If arguments are provided, parse them as `<name>` and optionally `<vault-path>`.
2. If no arguments, ask the user:
   - "What is your name?" (must match their folder name in `/team/<name>/`)
   - "Where is your Ingram Office vault?" (absolute path, e.g., `C:/Users/alex/Documents/ingram obsidian vault`)
3. Create the directory `~/.ingram-office/` and `~/.ingram-office/logs/` if they don't exist.
4. Write `~/.ingram-office/identity.json`:
   ```json
   {
     "name": "<name>",
     "vault": "<vault-path>"
   }
   ```
5. Verify the vault path exists and contains a `CLAUDE.md` file.
6. Verify `/team/<name>/` exists in the vault. If not, offer to create it by copying from `/team/_new_user/` and replacing placeholders.
7. Confirm: "Identity set: **<name>** at `<vault-path>`. You can now use `/check-in`, `/track-work`, `/aggregate`, and `/retro`."
