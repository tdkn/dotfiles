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

Install the latest mise with Homebrew.

```sh
brew install mise
brew upgrade mise
```

mise 2026.9.3 or later is required to prepend the managed Git include.

If an existing installation has a symlinked `~/.gitconfig`, migrate it to a
regular file before applying the bootstrap. See [Git configuration](#git-configuration).

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

```sh
mise run agents-sync
```

Add a local skill by creating `agents/skills/<name>/SKILL.md`, then rerun the
bootstrap or apply the dotfiles:

```sh
mise dotfiles apply
```

Two glob mappings in `.config/mise/conf.d/40-dotfiles.toml` link every local
skill directory into both `~/.agents/skills/` and `~/.claude/skills/`. New skills
need no individual mapping. apm installs third-party skills alongside these links.

Add a third-party skill by editing `apm/apm.yml`, running `mise run
agents-sync`, then committing the `apm/apm.lock.yaml` diff.

The GitButler skill ships with the `but` binary rather than through apm, so it
is installed separately. `mise run agents-sync` reports version drift after a
`brew upgrade`; resolve it with `but skill install --global`.

apm covers the user-scope skills described here. The
[skills](https://skills.sh/) CLI stays installed for project-scoped skills in
individual repositories.

## Git configuration

mise keeps `~/.gitconfig` as a regular local file. With `position = "prepend"`,
it adds this line before the existing contents when the line is missing:

```ini
[include] path = ~/.dotfiles/git/config
```

mise leaves an existing matching line in place. Keep the include before local
settings so those settings override shared defaults. `git config --global`
writes local settings to `~/.gitconfig`; edit `git/config` to change shared
settings.

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
