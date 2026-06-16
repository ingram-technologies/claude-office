# Porting `claude-office` to VS Code, Copilot, Codex, Gemini, and OpenCode

← [Back to README](README.md)

This repo started life as a **Claude Code plugin**, but it is already structured in a way that makes it portable:

- `skills/vault-awareness/` = reusable vault context
- `commands/*.md` = reusable operator workflows
- `hooks/session-start` and `hooks/session-end` = deterministic automation
- `~/.claude-office/` = local per-user state

That means the fastest way to support other agents is **not** to rewrite the system. The fastest way is to keep this repo as the canonical source and add **thin compatibility layers** for each target.

If you want to help push this further, **you are very welcome to adapt this repo for more agents, better packaging, or cleaner installers.**

This is just theory and research. If you experiment with it, you will see if it works and what is the best way to port it. And when you do, please open a PR about it to improve this document.

---

## Short answer

If you want the **least-effort** path:

1. **VS Code agent plugins / Copilot in VS Code (first choice for most people)**  
   Reuse the existing Claude-style plugin structure, then mirror `commands/*.md` into VS Code prompt files.
2. **GitHub Copilot CLI**  
   Add a small root `plugin.json` compatibility manifest and point it at the existing folders.
3. **OpenAI Codex**  
   Repackage the same content as a Codex plugin or Codex skills + hooks.
4. **Gemini CLI**  
   Wrap the same content in a `gemini-extension.json` extension.
5. **OpenCode**  
   Reuse the command markdown nearly as-is, then wrap hooks with a tiny JS/TS plugin.

The current repo is already closest to:

| Target | Fit | Why |
|---|---|---|
| VS Code agent plugins | **Very high** | VS Code can read Claude-format plugins, skills, and hooks |
| Copilot CLI | **High** | Plugin model supports commands, skills, hooks, MCP, marketplace |
| Codex | **High** | Skills, hooks, plugins, and marketplaces are all first-class |
| Gemini CLI | **High** | Extensions support commands, hooks, MCP, skills, agents |
| OpenCode | **Medium** | Commands fit well; hooks need a plugin wrapper |

---

## The core mapping

Treat the Claude plugin as the source of truth and map each part outward:

| Current `claude-office` piece | Meaning | Best portable form |
|---|---|---|
| `.claude-plugin/plugin.json` | package metadata | keep, then add target-specific manifest only where needed |
| `.claude-plugin/marketplace.json` | discovery/install metadata | keep, then add target marketplace/catalog files per system |
| `skills/vault-awareness/SKILL.md` | reusable vault awareness | portable skill / extension context / agent skill |
| `commands/*.md` | reusable slash workflows | prompt files, custom commands, or one-skill-per-command |
| `hooks/hooks.json` | event wiring | mostly portable, sometimes with path tweaks |
| `hooks/session-start` | inject context, sync vault | reuse directly where shell hooks exist |
| `hooks/session-end` | log work to the vault | reuse directly where shell hooks exist |
| `~/.claude-office/*` | user identity + run state | keep as-is or rename only if you want neutral branding |

The key design choice is simple:

> **Do not fork the logic. Reuse the same shell scripts and markdown instructions, and only adapt the packaging.**

---

## 1. VS Code agent plugins / Copilot in VS Code

This should be the **first** target because it is the most likely landing spot for people who want Copilot-like behavior in an editor.

### Why this is the best first adaptation

VS Code's preview **agent plugin** system can bundle:

- slash commands
- skills
- custom agents
- hooks
- MCP servers

It also explicitly recognizes **Claude-format plugins** via `.claude-plugin/plugin.json`, and it supports Claude-style hooks and the `${CLAUDE_PLUGIN_ROOT}` token.

### Most direct path

**Recommended:** keep this repo in Claude format and install it as a VS Code agent plugin, then add a small VS Code/Copilot compatibility layer for the commands.

### What already maps well

| `claude-office` piece | VS Code status |
|---|---|
| `.claude-plugin/plugin.json` | already in a recognized plugin format |
| `skills/vault-awareness/SKILL.md` | should port cleanly as an agent skill |
| `hooks/hooks.json` | Claude-compatible hook format is supported |
| `hooks/session-start` / `hooks/session-end` | directly reusable shell scripts |

### The one thing to adapt

VS Code's documented slash-command mechanism is **prompt files** (`.prompt.md`) and agent skills.  
So the safe path is:

- keep `commands/*.md` as the canonical source
- mirror them into `.github/prompts/*.prompt.md`

That is a **repackaging step**, not a rewrite.

### Does “copy everything globally instead of per project” work?

**Mostly yes.**

For personal use, VS Code supports **user-level** customizations:

- skills in `~/.copilot/skills/`, `~/.claude/skills/`, or `~/.agents/skills/`
- hooks in `~/.copilot/hooks` or `~/.claude/settings.json`
- prompt files at the user-profile level

So if your goal is:

> “I want this available in all my VS Code sessions”

then **yes**, a global install is viable.

But there is one nuance:

- **skills and hooks** copy over very naturally
- **commands** should become **user prompt files** or be delivered through the plugin bundle

So the practical answer is:

> **Yes, global works for Copilot/VS Code, but commands are better mirrored as prompt files than copied blindly as raw Claude command markdown.**

### Easiest VS Code rollout options

#### Option A — best overall: install as a plugin

Use the repo as a plugin bundle and keep it installable/updatable as one unit.

Good when:

- multiple people will use it
- you want one install/uninstall path
- you want hooks and skills to stay bundled

#### Option B — fastest personal setup: copy to user-level customizations

For one person experimenting locally:

1. Copy `skills/vault-awareness/` to `~/.copilot/skills/` or `~/.agents/skills/`
2. Copy or recreate the hook config in `~/.copilot/hooks`
3. Create user prompt files from `commands/*.md`
4. Keep the shell scripts and `~/.claude-office/identity.json` state as-is

### Recommended VS Code compatibility layer

Add these files without touching the core logic:

```text
.github/
  prompts/
    check-in.prompt.md
    aggregate.prompt.md
    retro.prompt.md
    setup-identity.prompt.md
    init.prompt.md
    import-activity.prompt.md
```

Each prompt file can be a thin wrapper around the corresponding command, using the same instructions with VS Code prompt-file frontmatter.

### Suggested verdict

If someone says “I use Copilot in VS Code, how do I use this?”, the cleanest answer is:

> **Install it as a VS Code agent plugin, keep the existing Claude structure, and mirror the commands into prompt files.**

That is the closest thing to a near-drop-in port.

---

## 2. GitHub Copilot CLI

Copilot CLI is more plugin-native than Copilot chat surfaces on GitHub itself.

### Why it is promising

Copilot CLI plugins support:

- `commands`
- `skills`
- `hooks`
- `mcpServers`
- `agents`

Plugins can be installed from:

- a local path
- GitHub
- a Git URL
- a marketplace

### Most direct path

Add a **root** `plugin.json` for Copilot CLI and point it at the existing repo folders.

That lets you keep:

- `skills/`
- `commands/`
- `hooks/`

without moving the real logic.

### Minimal compatibility manifest

Something in this shape is the easiest port:

```json
{
  "name": "claude-office",
  "description": "Ingram Office vault plugin",
  "version": "1.0.1",
  "skills": "skills/",
  "commands": "commands/",
  "hooks": "hooks/hooks.json"
}
```

### What ports cleanly

| `claude-office` piece | Copilot CLI status |
|---|---|
| `skills/vault-awareness/SKILL.md` | direct fit |
| `commands/*.md` | direct fit via plugin `commands` path |
| `hooks/hooks.json` | direct fit via plugin `hooks` field |
| shell hook scripts | reusable with path fixes |
| marketplace metadata | easy to add or mirror |

### What to watch

Copilot CLI expects its own root `plugin.json`, so this is **not** as zero-touch as VS Code's Claude-format plugin detection.

Still, the required work is small:

1. add root `plugin.json`
2. make sure hook script paths resolve correctly
3. install with `copilot plugin install ./path`

### Suggested verdict

This is a **small packaging job**, not a rewrite.

If someone wants a real CLI plugin and not a wrapper script, **Copilot CLI is workable**.

---

## 3. OpenAI Codex

Codex is a very good target because it has:

- skills
- hooks
- plugins
- plugin marketplaces
- repo/user/system skill locations

### Most direct path

For a personal or team port, the easiest route is:

1. keep the current markdown instructions and shell scripts
2. package them as a **Codex plugin**
3. expose the workflows as Codex skills

### Why skills matter in Codex

Codex treats skills as the reusable workflow unit, and plugins as the install/distribution unit.

That means the cleanest mapping is:

| `claude-office` piece | Codex target |
|---|---|
| `skills/vault-awareness/SKILL.md` | keep as a Codex skill |
| `commands/check-in.md` | convert to `skills/check-in/SKILL.md` |
| `commands/aggregate.md` | convert to `skills/aggregate/SKILL.md` |
| `commands/retro.md` | convert to `skills/retro/SKILL.md` |
| `commands/setup-identity.md` | convert to `skills/setup-identity/SKILL.md` |
| `hooks/session-start` | reuse in Codex hooks |
| `hooks/session-end` | reuse in Codex hooks |

### Why convert commands to skills here

Codex's strongest documented portability surface is **skills + plugins**, not “raw Claude command markdown.”

So the least-friction adaptation is:

- keep each command's body
- wrap it in a skill directory with `SKILL.md`

### Minimal plugin shape

```text
my-claude-office-codex-port/
  .codex-plugin/
    plugin.json
  skills/
    vault-awareness/
      SKILL.md
    check-in/
      SKILL.md
    aggregate/
      SKILL.md
    retro/
      SKILL.md
    setup-identity/
      SKILL.md
    init/
      SKILL.md
    import-activity/
      SKILL.md
  hooks/
    hooks.json
    session-start
    session-end
```

Minimal manifest:

```json
{
  "name": "claude-office",
  "version": "1.0.0",
  "description": "Vault-driven coordination workflows",
  "skills": "./skills/",
  "hooks": "./hooks/hooks.json"
}
```

### Global vs repo-local

Codex supports both:

- repo skills in `.agents/skills`
- user skills in `~/.agents/skills`
- user hooks in `~/.codex/hooks.json`
- project hooks in `<repo>/.codex/hooks.json`

So yes, a **global personal install** is viable here too.

### Suggested verdict

Codex is a **good target**.  
The easiest route is **“convert commands into skills, keep hooks, package as plugin.”**

---

## 4. Gemini CLI

Gemini CLI's extension model is strong and explicit.

### Why it fits

Gemini extensions can bundle:

- commands
- hooks
- skills
- sub-agents
- MCP servers
- extension context

Extensions are installed globally under `~/.gemini/extensions`, and local paths are supported for development.

### Most direct path

Create a `gemini-extension.json` wrapper and reuse the existing repo content:

- `vault-awareness` → `skills/` or `GEMINI.md`
- `commands/*.md` → `commands/*.toml`
- hooks → `hooks/hooks.json`
- shell scripts stay the same

### The main adaptation

Gemini custom commands are TOML files, so this is the main conversion:

| `claude-office` piece | Gemini target |
|---|---|
| `commands/check-in.md` | `commands/check-in.toml` |
| `commands/aggregate.md` | `commands/aggregate.toml` |
| `commands/retro.md` | `commands/retro.toml` |
| `commands/setup-identity.md` | `commands/setup-identity.toml` |

The command content itself can stay conceptually the same; it just needs Gemini's command format.

### Minimal extension shape

```text
claude-office-gemini/
  gemini-extension.json
  GEMINI.md
  commands/
    check-in.toml
    aggregate.toml
    retro.toml
    setup-identity.toml
  hooks/
    hooks.json
  skills/
    vault-awareness/
      SKILL.md
```

Example manifest skeleton:

```json
{
  "name": "claude-office",
  "version": "1.0.0",
  "description": "Vault-driven coordination workflows",
  "contextFileName": "GEMINI.md"
}
```

Then link or install it:

```bash
gemini extensions link /path/to/claude-office-gemini
```

### Global vs repo-local

Gemini extensions are already naturally **global-first**, which makes this a nice personal install target.

### Suggested verdict

Gemini is a **clean extension target**, but you do need a one-time **command format conversion**.

---

## 5. OpenCode

OpenCode deserves special mention because it is very close on some surfaces and very different on others.

### Why it is interesting

OpenCode supports:

- custom markdown commands
- MCP servers
- global and project config
- JS/TS plugins with event hooks

### The good news

`claude-office` command markdown is **already very close** to OpenCode's custom command model.

OpenCode supports:

- global commands in `~/.config/opencode/commands/`
- project commands in `.opencode/commands/`

That means `commands/*.md` are one of the easiest pieces to port.

### Most direct path

For OpenCode, the easiest route is:

1. copy/adapt `commands/*.md` into `.opencode/commands/` or `~/.config/opencode/commands/`
2. move vault-awareness into `AGENTS.md` or a companion command
3. wrap `session-start` and `session-end` in a tiny OpenCode plugin

### Why hooks are different here

OpenCode does not use the same Claude/Copilot/Codex-style hook JSON as its primary plugin model.

Instead, it uses **JS/TS plugins** that attach to events such as:

- `session.created`
- `session.idle`
- `tool.execute.before`
- `tool.execute.after`

So the shell scripts are reusable, but the event wiring must be rewritten as a small plugin.

### Easiest OpenCode hook wrapper

Keep the existing scripts and call them from a plugin:

```ts
export const ClaudeOffice = async ({ $ }) => ({
  "session.created": async () => {
    await $`/path/to/claude-office/hooks/session-start`
  },
  "session.idle": async () => {
    await $`/path/to/claude-office/hooks/session-end`
  }
})
```

That is the right kind of shim:

- **logic stays in the shell scripts**
- only the event adapter changes

### Global vs repo-local

OpenCode supports both:

- global commands in `~/.config/opencode/commands/`
- project commands in `.opencode/commands/`
- global plugins in `~/.config/opencode/plugins/`
- project plugins in `.opencode/plugins/`

So yes, this is another system where a **global personal install** makes sense.

### Suggested verdict

OpenCode is a **good target for commands**, and a **moderate-effort target for hooks**.

If you want the fastest OpenCode port:

> **port the commands first, then add a tiny JS/TS plugin that shells out to the existing hook scripts.**

---

## Suggested portability strategy for this repo

If the goal is to support multiple agents without turning this repo into a mess, the cleanest approach is:

### 1. Keep this repo as the canonical source

Do **not** duplicate the real logic across five agent ecosystems.

Keep canonical:

- `commands/*.md`
- `skills/vault-awareness/SKILL.md`
- `hooks/session-start`
- `hooks/session-end`

### 2. Add thin compatibility packaging only

Add small target-specific wrappers:

- `plugin.json` for Copilot CLI
- `.codex-plugin/plugin.json` for Codex
- `gemini-extension.json` for Gemini
- `.github/prompts/*.prompt.md` for VS Code prompt files
- `.opencode/plugins/*.ts` for OpenCode hook wiring

### 3. Prefer “reuse scripts, adapt manifests”

The shell scripts are the expensive part to get right. Reuse them.

The markdown workflows are the second expensive part. Reuse them.

The manifests are cheap. Rebuild those per ecosystem.

---

## Recommended order of implementation

If somebody actually wants to make this portable in practice, this is the lowest-pain order:

1. **VS Code plugin + prompt files**
2. **Copilot CLI plugin manifest**
3. **Codex plugin**
4. **Gemini extension**
5. **OpenCode plugin wrapper**

Why this order:

- VS Code gives the most users the quickest win
- Copilot CLI is a small manifest job
- Codex and Gemini are structured and worth doing right
- OpenCode is straightforward once the command layer is already portable

---

## Practical answer to “would global instead of per-project work?”

**Yes, in most of these systems.**

| System | Global install works? | Notes |
|---|---|---|
| VS Code / Copilot | **Yes** | especially for skills, hooks, prompt files, and installed plugins |
| Copilot CLI | **Yes** | plugin install is naturally user-level |
| Codex | **Yes** | `~/.agents/skills`, `~/.codex/hooks.json`, personal marketplace |
| Gemini CLI | **Yes** | extensions live under `~/.gemini/extensions` |
| OpenCode | **Yes** | `~/.config/opencode/commands` and `~/.config/opencode/plugins` |

The only caveat is that **global install is best for personal workflows**.  
If a team should share the same behavior, packaging or checking the files into the repo is usually better.

---

## Bottom line

`claude-office` is already portable because it is mostly:

- markdown workflows
- shell hooks
- local state

That is exactly the kind of system that ports well.

The **best immediate target** is **VS Code agent plugins / Copilot in VS Code**, because most people will meet the system there and the existing Claude-format plugin structure is already close.

After that:

- **Copilot CLI** is a small packaging task
- **Codex** is a strong plugin/skills target
- **Gemini** is a strong extension target
- **OpenCode** is a strong commands target with a small hook-wrapper tax

If you are interested in taking this further, **please do**. The repo is a good candidate for a multi-agent portability layer, and contributions that keep the logic shared while adding thin target adapters are exactly the right direction.

---

## References used for this portability note

- **VS Code agent plugins / skills / hooks / prompt files**
  - https://code.visualstudio.com/docs/agent-customization/agent-plugins
  - https://code.visualstudio.com/docs/agent-customization/overview
  - https://code.visualstudio.com/docs/agent-customization/hooks
  - https://code.visualstudio.com/docs/agent-customization/agent-skills
  - https://code.visualstudio.com/docs/agent-customization/prompt-files
- **GitHub Copilot CLI plugins**
  - https://docs.github.com/en/copilot/reference/copilot-cli-reference/cli-plugin-reference
- **OpenAI Codex**
  - https://developers.openai.com/codex/skills
  - https://developers.openai.com/codex/config-basic
  - https://developers.openai.com/codex/config-advanced
  - https://developers.openai.com/codex/cli/slash-commands
  - https://developers.openai.com/codex/plugins/build
- **Gemini CLI**
  - https://github.com/google-gemini/gemini-cli/blob/main/docs/extensions/index.md
  - https://github.com/google-gemini/gemini-cli/blob/main/docs/extensions/reference.md
- **OpenCode**
  - https://opencode.ai/docs
  - https://opencode.ai/docs/commands/
  - https://opencode.ai/docs/plugins/
  - https://opencode.ai/docs/mcp-servers/
  - https://opencode.ai/docs/config/
