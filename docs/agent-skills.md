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

The GitButler skill ships with the `but` binary rather than through apm, so it
is installed separately with `but skill install --global`. The bootstrap task
updates it when a `brew upgrade` leaves it behind the `but` version, and skips
the check on a machine without `but`.

## Migrating a symlinked `~/.apm`

If `~/.apm` is still a symlink to `apm/`, replace it with a regular directory
and remove the files apm left in the repository:

```sh
rm ~/.apm
mise bootstrap --yes --force-dotfiles
rm -rf ~/.dotfiles/apm/apm_modules ~/.dotfiles/apm/config.json
```
