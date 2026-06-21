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
mise dotfiles status --missing
mise bootstrap macos-defaults status --missing
mise bootstrap user status --missing
mise brew-sync
brew bundle check --no-upgrade --file ~/.config/homebrew/Brewfile
mise doctor
```

Run `mise brew-sync` after changing Homebrew formulae, casks, or Mac App Store
apps, then review the Brewfile diff before committing.

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
