# dotfiles

A reproducible macOS development environment powered by Lix/Nix, nix-darwin,
Home Manager, Homebrew, and mise.

This repository manages the core macOS setup, user environment, shell
configuration, and developer tooling from a single Nix flake.

## Quick Start

Clone the repository into a local workspace using HTTPS.

```sh
mkdir -p ~/ghq/github.com/tdkn
git clone https://github.com/tdkn/dotfiles.git ~/ghq/github.com/tdkn/dotfiles
cd ~/ghq/github.com/tdkn/dotfiles
```

Install Lix manually before applying the flake.

```sh
curl -sSf -L https://install.lix.systems/lix | sh -s -- install
nix --version # confirm Nix is installed
```

First-time activation (requires running nix-darwin directly through Nix).

```sh
sudo nix run github:nix-darwin/nix-darwin/master#darwin-rebuild -- switch --flake .#work-macbook
```

## Usage

Use `darwin-rebuild` for day-to-day changes after the first activation.

```sh
# Apply the configuration
sudo darwin-rebuild switch --flake .#work-macbook

# Build without switching
sudo darwin-rebuild build --flake .#work-macbook

# Update pinned inputs
nix flake update

# Validate the flake
nix flake check

# Roll back to the previous generation
sudo darwin-rebuild --rollback
```

Update the flake inputs before rebuilding when you want to move pinned dependencies forward.

## Git Signing

Git commit and tag signing use 1Password's SSH signing program. Create an
Ed25519 SSH key in 1Password, enable the 1Password SSH Agent, and add the
public key to GitHub as a signing key.

Keep the public signing key out of this repository in a local include file:

```ini
[user]
	signingkey = ssh-ed25519 ...
```

Save it at `~/.config/git/1password-signing.config`, then run
`darwin-rebuild switch --flake .#work-macbook`. The GitHub verified email must
match the configured Git commit email.

Git's primary config is `~/.gitconfig`; `~/.config/git` is only for the global
ignore file and local signing-key include.
