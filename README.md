# dotfiles

A reproducible macOS development environment powered by mise and Homebrew.

## Quick Start

Clone the repository and create the stable `~/.dotfiles` root.

```sh
mkdir -p ~/ghq/github.com/tdkn
git clone https://github.com/tdkn/dotfiles.git ~/ghq/github.com/tdkn/dotfiles
cd ~/ghq/github.com/tdkn/dotfiles
ln -sfn ~/ghq/github.com/tdkn/dotfiles ~/.dotfiles
```

Install the latest mise with the official installer. It installs the binary
to `~/.local/bin/mise`, and `zsh/profile.d/40-local-bin.zsh` adds that
directory to `PATH` once the bootstrap links the zsh profile.

```sh
curl -fsSL https://mise.run | sh
export PATH="$HOME/.local/bin:$PATH"
mise --version
```

Update mise with `mise self-update`. mise 2026.9.3 or later is required to
prepend the managed Git include.

If mise was installed with Homebrew, remove that copy after installing the
official binary so only one `mise` stays on `PATH`:

```sh
brew uninstall mise
```

If an existing installation has a symlinked `~/.gitconfig`, migrate it to a
regular file before applying the bootstrap. See [Git configuration](#git-configuration).
If `~/.apm` is a symlink, remove it first. See [Agent Skills](#agent-skills).

Trust, review, and apply the bootstrap.

```sh
mise trust --all
mise bootstrap --dry-run --force-dotfiles
mise bootstrap --yes --force-dotfiles
```

## Usage

Use mise to inspect or refresh the environment.

```sh
mise bootstrap --dry-run --force-dotfiles
mise bootstrap --yes --force-dotfiles
mise bootstrap status --missing
mise brew-sync
brew bundle check --no-upgrade --file ~/.config/homebrew/Brewfile
mise doctor
```

Run `mise brew-sync` after changing Homebrew formulae, casks, or Mac App Store
apps, then review the Brewfile diff before committing.

## Agent Skills

Skills come from two places. Locally authored skills live in `agents/skills/`
and mise symlinks them into the agent skill directories, so editing one takes
effect immediately and shows up as an unstaged change here. Third-party skills
are declared in `apm/apm.yml` and installed by
[apm](https://microsoft.github.io/apm) into the same directories.

apm refuses a symlinked `~/.apm`, so mise copies `apm/apm.yml` and
`apm/apm.lock.yaml` into a regular `~/.apm` directory. The bootstrap task runs
`apm install -g` and saves any lockfile change back to `apm/apm.lock.yaml`.

Add a local skill by creating `agents/skills/<name>/SKILL.md`, then rerun the
bootstrap or apply the dotfiles:

```sh
mise dotfiles apply
```

Two glob mappings in `.config/mise/conf.d/40-dotfiles.toml` link every local
skill directory into both `~/.agents/skills/` and `~/.claude/skills/`. New skills
need no individual mapping. apm installs third-party skills alongside these links.

Add a third-party skill by editing `apm/apm.yml`, rerunning the bootstrap, then
committing the `apm/apm.lock.yaml` diff.

Update third-party skills to their latest upstream commits with the task below.
It shows apm's update plan and asks for confirmation. Commit the resulting
`apm/apm.lock.yaml` diff.

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

If `~/.apm` is still a symlink to `apm/`, replace it with a regular directory
and remove the files apm left in the repository:

```sh
rm ~/.apm
mise bootstrap --yes --force-dotfiles
rm -rf ~/.dotfiles/apm/apm_modules ~/.dotfiles/apm/config.json
```

The GitButler skill ships with the `but` binary rather than through apm, so it
is installed separately with `but skill install --global`. The bootstrap task
updates it when a `brew upgrade` leaves it behind the `but` version.

apm covers the user-scope skills described here. The
[skills](https://skills.sh/) CLI stays installed for project-scoped skills in
individual repositories.

## Git configuration

mise manages this multiline include in a marker block in the regular local
`~/.gitconfig`:

```ini
[include]
	path = ~/.dotfiles/git/config
```

Keep the entire block, including its markers, at the top so local settings
override shared defaults. On first apply to an existing file, mise appends the
missing block; move it to the top once. Subsequent applies replace it in place.
`git config --global` writes local settings; edit `git/config` for shared
settings. Replace any existing shared include with the block to avoid loading
shared settings twice.

To migrate an existing symlink, save its contents, replace the link with a
regular file without changing `git/config`, and retain only intended local
overrides before applying the bootstrap. Review existing regular files for
copied shared values too, since those values can override later shared changes.
Check which file supplies a setting with:

```sh
git config --show-origin --get <key>
```

## Git Signing

Git commit and tag signing use 1Password's SSH signing program. Create an
Ed25519 SSH key in 1Password, enable the SSH Agent, and add the public key to
GitHub as a signing key.

Keep the signing key in a local include file:

```ini
[user]
	signingkey = ssh-ed25519 ...
```

Save it as `~/.config/git/1password-signing.config`, then rerun the bootstrap.
The GitHub verified email must match the configured Git commit email.

## License

MIT
