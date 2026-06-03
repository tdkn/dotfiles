# dotfiles

A curated macOS workstation configuration powered by Lix/Nix, nix-darwin, Home Manager, Homebrew, and mise. The
goal is to keep the machine reproducible without fighting the parts of macOS that are still best managed by native
tools.

## Directory Structure

```text
.
├── flake.nix
├── flake.lock
├── ghostty
│   └── config.ghostty
├── git
│   ├── config
│   └── ignore
├── nix
│   ├── home
│   │   └── tdkn
│   │       └── default.nix
│   ├── hosts
│   │   └── work-macbook
│   │       └── default.nix
│   └── modules
│       ├── darwin
│       │   ├── defaults.nix
│       │   └── homebrew.nix
│       └── home
│           └── packages.nix
└── zsh
    ├── ghq-clone.zsh
    ├── init.zsh
    └── profile.zsh
```

- `flake.nix` is the entry point for the full configuration. It pins inputs, exposes the `work-macbook` nix-darwin
  configuration, and defines the project formatter.
- `nix/hosts/work-macbook/default.nix` contains the host-level macOS configuration, including Nix settings, networking
  identity, the system user, and Home Manager integration.
- `nix/home/tdkn/default.nix` defines the user environment: shell behavior, session variables, mise integration, and
  app config links.
- `nix/modules/darwin/defaults.nix` collects macOS user defaults for Finder and other system applications.
- `nix/modules/darwin/homebrew.nix` declares Homebrew formulae, casks, fonts, and activation behavior for macOS-native
  software.
- `nix/modules/home/packages.nix` is reserved for user-scoped Nix packages that should live outside dedicated Home Manager
  program modules.
- `ghostty/`, `git/`, and `zsh/` hold app-specific configuration files linked or read by Home Manager. Git config is
  linked to `$XDG_CONFIG_HOME/git/config`.

## Installation

Clone the repository into a local workspace using HTTPS.

```sh
mkdir -p ~/ghq/github.com/tdkn
git clone https://github.com/tdkn/dotfiles.git ~/ghq/github.com/tdkn/dotfiles
cd ~/ghq/github.com/tdkn/dotfiles
```

Install Lix manually before applying the flake.

```sh
curl -sSf -L https://install.lix.systems/lix | sh -s -- install
```

Open a new shell and confirm that Nix is available.

```sh
nix --version
```

On the first activation, `darwin-rebuild` may not exist on the machine yet, so run nix-darwin directly through Nix.

```sh
sudo nix run github:nix-darwin/nix-darwin/master#darwin-rebuild -- switch --flake .#work-macbook
```

## Usage

After the initial activation, use the installed `darwin-rebuild` command for normal rebuilds.

```sh
sudo darwin-rebuild switch --flake .#work-macbook
```

Build the configuration without switching when you want to validate changes before applying them.

```sh
sudo darwin-rebuild build --flake .#work-macbook
```

Update pinned flake inputs, then rebuild the host.

```sh
nix flake update
sudo darwin-rebuild switch --flake .#work-macbook
```

Run the standard checks when reviewing changes.

```sh
nix flake check
sudo darwin-rebuild build --flake .#work-macbook
brew ls --installed-on-request
brew ls --casks -1
hostname
scutil --get LocalHostName
command -v darwin-rebuild
```

If a switch introduces a problem, roll back to the previous generation.

```sh
sudo darwin-rebuild --rollback
```

### Uninstall Lix/Nix

To remove the Lix-provided Nix installation, run the Lix Installer uninstaller.

```sh
/nix/lix-installer uninstall
```

This disables `darwin-rebuild`, nix-darwin, and Home Manager until Lix/Nix is installed again. The dotfiles repository
and Homebrew-installed apps are not removed by this command.
