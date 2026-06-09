# Level 1: The Dry-Run Dungeon

← [Back to README](README.md)

> A safe, throwaway walkthrough of the value loop. No real projects touched. Goal: **see the loop produce artifacts with your own eyes** so the mental model becomes real before you point this at work that matters. We recommend running this with a small model, like haiku or sonnet on medium effort.

**Time:** ~20 minutes  
**Risk:** zero — everything happens in a sandbox folder you delete at the end  
**Prerequisite:** Claude Code installed, and you've read [The Mental Model](README.md#the-mental-model)

---

## The Quest

You will create a fake vault and a fake project, run one tiny work session, then watch the loop turn that session into a shared briefing. By the end you'll have *witnessed* each of the 4 chunks doing its job.

Keep the [Stage 0 diagram](README.md) open beside you. Each step below maps to a chunk.

---

## Step 1 — Build the sandbox

Make two throwaway folders: one to become the **hub** (vault), one to be a fake **spoke** (project).

```bash
mkdir -p ~/sandbox-office/vault
mkdir -p ~/sandbox-office/fake-project
cd ~/sandbox-office/fake-project
git init
echo "# Fake Project" > README.md
git add . && git commit -m "init sandbox project"
```

> **Path tip:** use `~/` for an absolute path from your home directory (works from anywhere), or `./` for a path relative to your current folder (shorter, but only correct if you launch Claude Code from the right directory). Pick one style and use it consistently throughout — mixing them is the main source of "vault not found" errors.

> 🔍 **Witness (Chunk 2 — Your Repos):** `fake-project/` is an ordinary git repo. Nothing special about it. This is what a spoke looks like.

---

## Step 2 — Install and initialize

If you haven't already installed the plugin (see [Setup](README.md#setup)), do that first. Then, inside the fake project:

```bash
/claude-office:init test-user ~/sandbox-office/vault
/claude-office:setup-identity test-user ~/sandbox-office/vault
```

> 🔍 **Witness (Chunk 1 — The Hub):** open `~/sandbox-office/vault` in your file browser or Obsidian. You'll see the vault structure appear — `team/test-user/` and a profile file. This is mission control, freshly built.  

> **Permission error?** If you see `Permission denied` on the hook,
> the plugin installer didn't set the executable bit. Fix it and restart:
>
> ```bash
> chmod +x ~/.claude/plugins/cache/ingram-technologies/claude-office/1.0.1/hooks/*
> ```
>
> Then restart Claude Code. The hooks will fire correctly on the next session.

---

## Step 3 — Restart, then do a tiny "work" session

Restart your Claude Code session so the hooks activate. Then do something trivially small but real — for example:

```
Ask Claude Code: "Add a line to README.md that says 'hello from the dry run'."
```

Let it make the edit. Then **end the session** (close Claude Code or start a fresh one).

> 🔍 **Witness (Chunk 3 — The Hooks):** after the session ends, look in `vault/team/test-user/activity/`. A new `activity-*.md` file should appear, capturing what you just did. You never told it to — `session-end` did it silently.

---

## Step 4 — Run the loop

Now turn that raw activity into synthesized state:

```bash
/claude-office:aggregate
```

> 🔍 **Witness (Chunk 4 — The Value Loop, part 1):** check the project's `status.md` in the vault. Your activity has been parsed into a per-person "Team Notes" section. Raw logs became structured state.

Then ask for it back:

```bash
/claude-office:check-in
```

> 🔍 **Witness (Chunk 4 — The Value Loop, part 2):** Claude Code hands you a briefing — what you last did, what's in progress. This is the payoff: the loop closed, and context came *back* to you.

---

## Step 5 — Reflect on what you saw

You just watched raw work become shared memory and return as a briefing. Map it back:

| You saw... | Which proves... |
|---|---|
| The vault folder appear | The Hub exists and is just files |
| The fake repo stay normal | Spokes are untouched |
| `activity-*.md` appear unprompted | The Hooks fire automatically |
| `status.md` fill in, then a briefing | The Value Loop closes |

If all four happened, the mental model is now **confirmed by experience**, not just explained.

---

## Step 6 — Tear down

No trace left behind:

```bash
rm -rf ~/sandbox-office
```

If you created any local state during the dry run, clear it too:

```bash
rm -rf ~/.claude-office
```

> Note: only do this if `~/sandbox-office` was your *only* claude-office setup. If you already use it for real work, **skip this line** — it would wipe your real identity config.

---

## Boss Defeated 🏆

You've run the full loop end-to-end with zero risk. You now know, from having seen it:

- where the vault lives and what it contains
- that your repos stay clean
- that the hooks need a session restart to wake up
- what `/claude-office:aggregate` and `/claude-office:check-in` actually produce

**Next: Level 2** — repeat this on *one real, low-stakes repo*. Same steps, real work. When `/claude-office:check-in` saves you from re-reading your own notes, the system has earned its place.

---

*Optional side-quest:* if you want to feel the structural-memory layer too, run `/graphify .` in the sandbox project and open the `graph.html` it produces. See [INTEGRATIONS.md](INTEGRATIONS.md) for how that layer pairs with this one.
