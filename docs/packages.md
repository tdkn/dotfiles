# Packages

The bootstrap runs the Homebrew `packages` task on Apple Silicon and
installs the ports and apps declared under `[bootstrap.packages]`.

## Homebrew on Apple Silicon

`homebrew/Brewfile` lists the formulae and casks.

```sh
mise brew-sync
brew bundle check --no-upgrade --file ~/.config/homebrew/Brewfile
```

Run `mise brew-sync` after changing Homebrew formulae or casks, then review
the Brewfile diff before committing.

## Mac App Store on Apple Silicon

`[bootstrap.packages]` in `.config/mise/config.macos-arm64.toml` lists the
Mac App Store apps as `mas:<id>` entries. Find an ID with `mas search <name>`.

On a fresh Mac, run the initial bootstrap to install `mas`. The package phase
runs before mise installs tools, so it skips these apps if `mas` is unavailable.
After signing in to the App Store, preview and apply the App Store packages:

```sh
mise bootstrap packages apply --manager mas --dry-run
mise bootstrap packages apply --manager mas
```

Removing an entry does not uninstall the app.

## MacPorts on Intel

The Intel config lists ports as `macports:<name>` entries. Bootstrap installs
missing ports with the default variants and leaves active installations in place,
including `curl` installed with custom variants.

```sh
mise bootstrap packages status
port installed
port outdated
```

Use `mise bootstrap --only packages --update` to refresh the ports tree
before installing missing ports. Use `sudo port selfupdate` to update
MacPorts itself.

## macOS apps on Intel

`[bootstrap.packages]` in `.config/mise/config.macos-x64.toml` lists apps
installed by mise from Homebrew cask metadata. This does not require Homebrew,
but mise uses `sudo` to create a Homebrew-style prefix at `/opt/homebrew` and
records installed casks under `/opt/homebrew/Caskroom`. The Tailscale
package installer also requires administrator authentication. See
[Tailscale](tailscale.md) for its first-run setup and update behavior.

```sh
mise bootstrap packages apply --manager brew-cask --dry-run
mise bootstrap packages apply --manager brew-cask
```
