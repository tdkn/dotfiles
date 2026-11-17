# Packages

The bootstrap runs a `packages` task that mise selects by architecture.

## Homebrew on Apple Silicon

`homebrew/Brewfile` lists the formulae, casks, and Mac App Store apps.

```sh
mise brew-sync
brew bundle check --no-upgrade --file ~/.config/homebrew/Brewfile
```

Run `mise brew-sync` after changing Homebrew formulae, casks, or Mac App Store
apps, then review the Brewfile diff before committing.

## MacPorts on Intel

The ports are listed in `.config/mise/config.macos-x64.toml`. The bootstrap
installs the missing ones.

```sh
port installed
port outdated
```
