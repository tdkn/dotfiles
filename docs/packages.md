# Packages

Bootstrap installs Homebrew formulae on Apple Silicon and MacPorts ports on
Intel. On both architectures, mise installs casks from `[bootstrap.packages]`.

## Homebrew on Apple Silicon

`homebrew/Brewfile` lists the formulae installed by the `packages` task.

```sh
mise brew-sync
brew bundle check --no-upgrade --file ~/.config/homebrew/Brewfile
```

Run `mise brew-sync` after changing installed formulae, then review the
Brewfile diff before committing.

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

## macOS apps and fonts

Declare casks in `.config/mise/conf.d/35-casks.toml`. Use `os = "macos"` and
set `env = "macos-arm64"` for Apple Silicon or `env = ["macos-arm64", "macos-x64"]`
for both architectures. Before enabling an Intel cask, check that the vendor
supports macOS 13 Ventura and that the cask can install without formula dependencies.

mise reads Homebrew cask metadata and records its installations under
`/opt/homebrew/Caskroom` on both architectures. Creating the prefix on a fresh
Intel Mac and installing system packages can require administrator authentication.
Login shells find cask commands in `/opt/homebrew/bin`, with MacPorts taking
precedence on Intel. See [Tailscale](tailscale.md) for network extension setup.

```sh
mise bootstrap packages apply --manager brew-cask --dry-run
mise bootstrap packages apply --manager brew-cask
```

`apply` and `upgrade` skip casks that mise detects as Homebrew-managed.
Check `managed_by` in `mise bootstrap packages status --json` to see which
manager owns a cask. [mise brew-cask documentation](https://mise.jdx.dev/bootstrap/packages/brew-cask.html#casks-installed-by-homebrew)

### Updates

```sh
mise bootstrap packages upgrade --manager brew-cask --dry-run
mise bootstrap packages upgrade --manager brew-cask
```

Apps marked `auto_updates` normally update themselves. After updating
GitButler, bootstrap checks its bundled CLI skill.
