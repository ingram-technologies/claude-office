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
`session-end` extracts user *prompts* from the conversation transcript — what you were trying to do — not just which files changed. This makes the logs meaningful context for future sessions, not just a diff redundant to the github history.


**Hooks for deterministic work.**  
Hooks are shell scripts, not AI calls. Pull on start, log on end, commit/push is always manual. This keeps the automatic layer predictable and fast, with zero token cost and avoids damaging the AI's capabilities with extra context.

**node is the one guaranteed dependency.**  
Hooks parse JSON and conversation transcripts with `node`, never python. Claude Code is itself a Node.js app, so node is present on every machine that can run a hook — whereas python3 is often absent (notably on Windows). Treating node as a hard dependency is *more* portable than a python fallback, not less. Both hooks bail cleanly if node is somehow missing.

**Scripts stay POSIX-portable.**  
Hooks run on Linux, macOS (BSD coreutils, bash 3.2), and Git Bash on Windows. They avoid GNU-only flags (`sed -i`, `grep -P`, `readlink -f`, `date -d`) and are pinned to LF line endings via `.gitattributes` — CRLF would break them under Git Bash (`$'\r': command not found`). The `run-hook.cmd` polyglot wrapper lets the same entry point work from cmd.exe and from a Unix shell.


**Sharing is opt-in, not opt-out.**  
A session whose working directory matches no entry in `routes` logs to `team/<you>/activity/private/`, which vaults gitignore. Publishing a repo to the team is an explicit act — adding it to `routes` in `identity.json`. The alternative (share everything, blacklist what hurts) fails silently and fails late: you find out a client repo leaked after it is already pushed. Defaulting to private makes the failure mode "my teammates can't see this yet", which is recoverable.

**Incremental aggregation.**  
`/aggregate` uses git-diff change detection and only rebuilds project status files that have new activity since the last run. It tracks state in `~/.claude-office/aggregation-state.json`.


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


---

## Recommendations

We recommend the [Obsidian Web Clipper](https://obsidian.md/clipper) extension for easily adding web pages and research to your project folders in the vault.

We recommend adding the [Obsidian Skills Plugin](https://github.com/kepano/obsidian-skills) to make claude better able to interact with obsidian (made by kephano himself)

A mention of honor goes to the [caveman](https://github.com/juliusbrussee/caveman) skill in order to save tokens if you don't need wordy descriptions.

Finally, [graphify](https://graphify.net/) is a good tool to help AI understand your graph, [playwright](https://playwright.dev/) to give AI better testing abilities and don't forget to use a memory system like [supermemory](https://supermemory.ai/) or even [arcscontexta](https://www.arscontexta.org/) if you're experienced with claude code.
