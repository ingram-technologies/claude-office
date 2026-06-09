# Architecture & Design Decisions

How claude-office works under the hood, and why it was built this way.

← [Back to README](README.md)

---

## Folder Structure

```
hooks/
  session-start     — git pull, inject identity + counts (deterministic shell)
  session-end       — parse transcript, log prompts + changes (deterministic shell)

commands/
  *.md              — slash commands (self-contained instruction files for Claude)

skills/
  vault-awareness/  — context skill for understanding vault structure
```

---

## Key Design Decisions

**Activity log captures intent, not just output.**  
`session-end` extracts user *prompts* from the conversation transcript — what you were trying to do — not just which files changed. This makes the logs meaningful context for future sessions, not just a diff.

**Activity logs are the primary lens.**  
`/aggregate` reads session logs to understand work done in *external repos*, not just edits to the vault itself. The vault is the output, not the input.

**Hooks for deterministic work.**  
Hooks are shell scripts, not AI calls. Pull on start, log on end, commit/push is always manual. This keeps the automatic layer predictable and fast, with zero token cost and avoids damaging the AI's capabilities with extra context.

**node is the one guaranteed dependency.**  
Hooks parse JSON and conversation transcripts with `node`, never python. Claude Code is itself a Node.js app, so node is present on every machine that can run a hook — whereas python3 is often absent (notably on Windows). Treating node as a hard dependency is *more* portable than a python fallback, not less. Both hooks bail cleanly if node is somehow missing.

**Scripts stay POSIX-portable.**  
Hooks run on Linux, macOS (BSD coreutils, bash 3.2), and Git Bash on Windows. They avoid GNU-only flags (`sed -i`, `grep -P`, `readlink -f`, `date -d`) and are pinned to LF line endings via `.gitattributes` — CRLF would break them under Git Bash (`$'\r': command not found`). The `run-hook.cmd` polyglot wrapper lets the same entry point work from cmd.exe and from a Unix shell.


**Incremental aggregation.**  
`/aggregate` uses git-diff change detection and only rebuilds project status files that have new activity since the last run. It tracks state in `~/.claude-office/aggregation-state.json`.

**Session-end is scoped to the user.**  
`session-end` only ever writes to `team/<you>/`. It cannot touch other team members' folders, even if their names appear in the conversation.

**`tasks.md` is personal.**  
Your todo list lives in your own section of the vault. It is not a team-managed task system. Team coordination happens through GitHub Issues, not through the vault. Higher level instructions can sit in the vault, if they do not sit in the github repo itself. What matters is that they get updated.

**Writer/reader chain is one-directional.**

```
session-end  →  activity logs  →  /aggregate  →  status.md  →  /check-in / /retro
```

Each stage reads only from the previous stage's output. Nothing loops back or mutates upstream files.

---

## Vault Template

Running `/init` clones from [ingram-technologies/claude-office-vault](https://github.com/ingram-technologies/claude-office-vault), which provides the base folder structure and Obsidian config. You can fork it to customize the structure for your team.

The vault is designed to be kept on `master` as a bare template — work on a branch for team customizations so you can pull upstream updates cleanly.

---

## Recommendation

We recommend the [Obsidian Web Clipper](https://obsidian.md/clipper) extension for easily adding web pages and research to your project folders in the vault.
