# AGENTS.md

## Project Overview

This repository contains dotfiles for a reproducible macOS development
environment managed by mise and Homebrew. The root is intended to be symlinked
as `~/.dotfiles`, and mise manages the individual symlinks into the home
directory.

Key areas:

- `.config/mise/config.toml` and `.config/mise/conf.d/*.toml`: mise settings,
  tool versions, shell aliases, bootstrap steps, dotfile symlinks, and tasks.
- `homebrew/Brewfile`: Homebrew formulae and casks installed by the bootstrap
  task.
- `zsh/`: `.zprofile`, `.zshrc`, and sourced profile/rc fragments.
- `git/`: shared Git config and global ignore rules.
- `ghostty/`: Ghostty terminal configuration.
- `karabiner/`: Karabiner-Elements keyboard configuration.
- `codex/AGENTS.md` and `claude/CLAUDE.md`: assistant-specific global
  instructions that are symlinked into each tool's config directory.
- `agents/skills/`: locally authored agent skills, symlinked into the agent
  skill directories by mise.
- `apm/`: the Agent Package Manager manifest and lockfile for third-party
  skills. mise copies both files into `~/.apm`, which must stay a regular
  directory because apm refuses a symlinked `~/.apm`.

There is no application build, package manifest, database, or test suite in
this repository.

## Setup Commands

- Install mise 2026.9.3 or newer with the official installer:
  `curl -fsSL https://mise.run | sh`
  It installs to `~/.local/bin/mise`; update it with `mise self-update`.
- Trust local mise configuration: `mise trust --all`
- Preview bootstrap changes: `mise bootstrap --dry-run --force-dotfiles`
- Apply bootstrap changes: `mise bootstrap --yes --force-dotfiles`
- Check all declared bootstrap state: `mise bootstrap status --missing`
  This includes dotfile links and edits, macOS settings, services, user settings,
  and tools. Check Brewfile packages separately with the command below.
- Check Homebrew dependencies without installing:
  `brew bundle check --no-upgrade --file ~/.config/homebrew/Brewfile`
- Inspect mise health: `mise doctor`

Use the dry-run/status commands before applying bootstrap changes. The
bootstrap can change symlinks, Homebrew packages, macOS defaults, and login shell
state.

## Development Workflow

- Keep changes small and focused; these files affect the user's real shell,
  editor, terminal, keyboard, Git, and package environment.
- Update mise-managed dotfile mappings in `.config/mise/conf.d/40-dotfiles.toml`
  when adding, moving, or removing tracked configuration files.
- Update `.config/mise/conf.d/10-tools.toml` for mise-managed runtimes and CLI
  tools. The configured npm package manager is `pnpm`.
- Update `.config/mise/conf.d/50-tasks.toml` for bootstrap task behavior.
- Update `homebrew/Brewfile` for Homebrew-managed packages; do not add ad hoc
  install scripts unless they are needed outside Homebrew or mise.
- For zsh, keep `zsh/profile.zsh` and `zsh/zshrc` as loaders. Put login-shell
  setup in `zsh/profile.d/*.zsh` and interactive shell setup in
  `zsh/rc.d/*.zsh`.
- When changing assistant instructions, keep each tool-specific file internally
  consistent. Do not copy private local paths, secrets, tokens, hostnames, cache
  paths, or session logs into committed files.

## Agent Skills

Locally authored skills live in `agents/skills/<skill-name>/SKILL.md`. Because
mise symlinks each one into the agent skill directories, edits take effect
immediately and show up as unstaged changes in this repository.

- Add a skill by creating `agents/skills/<skill-name>/SKILL.md`, then rerunning
  `mise dotfiles apply`. Glob mappings link every local skill directory into
  both `~/.agents/skills/` and `~/.claude/skills/`; no per-skill mapping is needed.
  Third-party skills installed by apm in those directories remain independent.
- Keep front matter valid: `name` and `description` are required, and the
  description is what the agent matches against when deciding to load the skill.
- Write skill text in English. Skills are procedural, so commands and file paths
  must be copy-paste accurate.
- Third-party skills are declared in `apm/apm.yml` and installed by the
  bootstrap task, which saves lockfile changes back to `apm/apm.lock.yaml`.
  Update them with `mise run skills-update`; do not hand-edit
  `apm/apm.lock.yaml`.
- Do not pin a third-party skill that its upstream repository removed. Run
  `apm uninstall -g <package>`, then
  `mise dot add ~/.apm/apm.yml ~/.apm/apm.lock.yaml`.
- Skills under `.agents/skills/` are scoped to this repository and are not
  distributed globally.

## Validation

Run the smallest relevant checks for the files you changed:

- General mise and bootstrap sanity:
  `mise bootstrap --dry-run --force-dotfiles`
- Aggregate bootstrap state: `mise bootstrap status --missing`
- Dotfile mapping sanity: `mise dotfiles status --missing`
- Homebrew changes:
  `brew bundle check --no-upgrade --file ~/.config/homebrew/Brewfile`
- mise config changes: `mise doctor`
- Karabiner configuration:
  `'/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli' --lint-complex-modifications karabiner/karabiner.json`
- Markdown changes: manually inspect rendered structure and fenced code blocks.
- Shell changes: start a fresh zsh session or source the changed fragment only
  after reviewing it for side effects.

This repository does not currently define automated unit, integration, or e2e
tests.

## Code Style

- Prefer plain, readable configuration over helper layers or generated files.
- Keep existing formatting style in each file:
  - TOML files use concise tables and quoted keys only where needed.
  - zsh files use simple guards such as `command -v ... >/dev/null 2>&1`.
  - Markdown uses short sections and exact commands.
  - JSON should remain valid and deterministic; use a structured formatter when
    making broad Karabiner edits.
- Comments should explain durable constraints or non-obvious behavior, not the
  reason a particular editing session changed something.
- Avoid adding personal or machine-specific data to committed files. Prefer
  local include files or documented placeholders for private values.

## Security And Privacy

- Never commit secrets, API tokens, credentials, private keys, local absolute
  paths, hostnames, cache paths, or session logs.
- Git signing keys are expected to live in a local Git include file, not in this
  repository.
- Keep `~/.gitconfig` as a regular, machine-local file. mise manages the include
  of `git/config` in a marker block. Keep the entire block at the top so local
  settings override shared defaults. First apply to an existing file appends
  the block; move it to the top once. Later applies preserve its position.
  Edit `git/config` for shared settings. `git config --global` writes local ones.
  When migrating a symlink, preserve local settings in a regular file before
  applying the block. Replace an existing shared include rather than keeping
  both, to avoid loading shared settings twice.
- Treat `git/config`, assistant instruction files, shell startup files, and
  Homebrew casks as sensitive because they affect authentication, command
  execution, and installed applications.

## Pull Request Guidelines

- Use `.github/pull_request_template.md` for pull requests.
- Before opening a PR, run the relevant validation commands listed above and
  mention any commands that could not be run.
