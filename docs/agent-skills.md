# Agent skills

Skills come from two places. Locally authored skills live in `agents/skills/`
and mise symlinks them into the agent skill directories, so editing one takes
effect immediately and shows up as an unstaged change here. Third-party skills
are declared in `apm/apm.yml` and installed by
[apm](https://microsoft.github.io/apm) into the same directories.

apm refuses a symlinked `~/.apm`, so mise copies `apm/apm.yml` and
`apm/apm.lock.yaml` into a regular `~/.apm` directory. The bootstrap task runs
`apm install -g --frozen` using the committed lockfile. Frozen installation can
deploy files before reporting an error; it does not change the lockfile.

apm covers the user-scope skills described here. The
[skills](https://skills.sh/) CLI stays installed for project-scoped skills in
individual repositories.

## Local skills

Add a local skill by creating `agents/skills/<name>/SKILL.md`, then rerun the
bootstrap or apply the dotfiles:

```sh
mise dotfiles apply
```

Two glob mappings in `.config/mise/conf.d/40-dotfiles.toml` link every local
skill directory into both `~/.agents/skills/` and `~/.claude/skills/`. New skills
need no individual mapping. apm installs third-party skills alongside these links.

## Third-party skills

Add a third-party skill in `apm/apm.yml` with its upstream branch as a ref,
such as `#main`. Copy the manifest, install, and save the updated lockfile:

```sh
mise dotfiles apply --force --yes ~/.apm/apm.yml
apm install -g
mise dot add ~/.apm/apm.lock.yaml
```

Review and commit the `apm/apm.lock.yaml` diff.

Dependabot checks these refs weekly and opens pull requests that update the
lockfile. Rerun the bootstrap after merging an update to install the skills.

To update skills to their latest upstream commits manually, use the task below.
apm shows an update plan and asks for confirmation. The task reinstalls the
resolved skills before saving the lockfile; review and commit the diff.

```sh
mise run skills-update
```

Skills removed from their upstream repository are not kept at an old commit.
An update that reports `Subdirectory '...' not found in repository` points to
one. Uninstall it and save both files back before updating again:

```sh
apm uninstall -g <package>
mise dot add ~/.apm/apm.yml ~/.apm/apm.lock.yaml
```

## GitButler skill

GitButler ships its skill with the `but` binary. Install it with
`but skill install --global`. After the mise-managed GitButler app updates,
the bootstrap task brings the skill up to the installed CLI version.
The task skips this check on a machine without `but`.

## Yaak skill

The `use-yaak` skill ships with the Yaak CLI (`npm:@yaakapp/cli` in mise), so
it is installed with `yaak agent install` rather than through apm. The command
writes `use-yaak/` into each detected agent skill directory under `~/.agents`,
`~/.claude`, `~/.codex`, `~/.cursor`, and `~/.opencode`. It stamps the CLI
version into the skill and overwrites local edits. Nothing runs it automatically,
including Yaak Desktop and CLI upgrades. After upgrading the CLI, `yaak --help`
reports whether the skill is out of date; rerun the command then:

```sh
yaak agent install
```

Do not add `use-yaak` to `apm/apm.yml`. apm would track the same files,
and the next `yaak agent install` would make `apm install -g --frozen`
fail with `no trustworthy local deployment baseline`.

## Migrating a symlinked `~/.apm`

If `~/.apm` is still a symlink to `apm/`, replace it with a regular directory
and remove the files apm left in the repository:

```sh
rm ~/.apm
mise bootstrap --yes --force-dotfiles
rm -rf ~/.dotfiles/apm/apm_modules ~/.dotfiles/apm/config.json
```
