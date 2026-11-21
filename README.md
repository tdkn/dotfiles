# dotfiles

A reproducible macOS development environment powered by
[mise](https://mise.jdx.dev/). One bootstrap links the dotfiles, installs
packages and tools, and applies macOS settings. Homebrew manages packages on
Apple Silicon, and MacPorts manages them on Intel.

## Quick Start

Clone the repository and link it as `~/.dotfiles`.

```sh
mkdir -p ~/ghq/github.com/tdkn
git clone https://github.com/tdkn/dotfiles.git ~/ghq/github.com/tdkn/dotfiles
cd ~/ghq/github.com/tdkn/dotfiles
ln -sfn ~/ghq/github.com/tdkn/dotfiles ~/.dotfiles
```

Install mise 2026.11.11 or later with the official installer.

```sh
curl -fsSL https://mise.run | sh
export PATH="$HOME/.local/bin:$PATH"
```

Trust, review, and apply the bootstrap from the repository directory.
`MISE_AUTO_ENV=true` is needed on the first run only.

```sh
export MISE_AUTO_ENV=true
mise trust --all
mise bootstrap --dry-run --force-dotfiles
mise bootstrap --yes --force-dotfiles
```

Read [Setup](docs/setup.md) before the first bootstrap on an Intel Mac or on
a machine that already has dotfiles.

## Usage

Rerun the bootstrap after changing the configuration, and check the
environment at any time.

```sh
mise bootstrap --dry-run --force-dotfiles
mise bootstrap --yes --force-dotfiles
mise bootstrap status --missing
mise doctor
```

## Documentation

- [Setup](docs/setup.md): requirements, Intel Macs, and existing installations.
- [Packages](docs/packages.md): Homebrew, MacPorts, and macOS apps.
- [Tailscale](docs/tailscale.md): setup and connectivity between Macs.
- [Agent skills](docs/agent-skills.md): local and third-party agent skills.
- [Git](docs/git.md): shared Git configuration and commit signing.

## License

MIT
