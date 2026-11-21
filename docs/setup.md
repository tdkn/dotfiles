# Setup

The [Quick Start](../README.md#quick-start) lists the initial bootstrap commands.

## mise

The official installer puts the binary in `~/.local/bin/mise`, and
`zsh/profile.d/40-local-bin.zsh` adds that directory to `PATH` once the
bootstrap links the zsh profile. Update mise with `mise self-update`.

If mise was installed with Homebrew, remove that copy after installing the
official binary so only one `mise` stays on `PATH`:

```sh
brew uninstall mise
```

## First run

Run the first bootstrap from the repository directory. Until the first apply
links the config into `~/.config/mise`, mise finds it only there.

`MISE_AUTO_ENV=true` loads the config for this machine's architecture, which
defines the `packages` task. Later runs get the setting from the linked
`miserc.toml`, so the variable is needed on the first run only.

The bootstrap applies macOS settings, and some of them require Full Disk
Access for the terminal app. Grant it under Privacy & Security in System
Settings before applying.

## Intel Macs

Install the Xcode Command Line Tools before the bootstrap. On macOS 13, the
bootstrap installs [MacPorts](https://www.macports.org/) when it is missing;
on other versions, install it manually first.

The MacPorts installer may add `PATH` lines to `~/.zprofile`. The bootstrap
replaces that file with the managed profile, which adds the MacPorts paths.

## Existing installations

- If `~/.gitconfig` is a symlink, migrate it to a regular file before applying
  the bootstrap. See [Git](git.md#shared-configuration).
- If `~/.apm` is a symlink, remove it first. See
  [Agent skills](agent-skills.md#migrating-a-symlinked-apm).

## Apply individual changes

After editing a dotfile mapping or a macOS preference, preview and apply the
affected configuration. For a dotfile, pass the destination path:

```sh
mise dotfiles apply --dry-run ~/.config/ghostty/config.ghostty
mise dotfiles apply ~/.config/ghostty/config.ghostty
```

If an existing file conflicts with the mapping, review it before passing
`--force` to replace it. On Intel, applying even one dotfile runs the MacPorts
setup hook. A dry run prints the hook without running it.

For macOS preferences:

```sh
mise bootstrap macos defaults apply --dry-run
mise bootstrap macos defaults apply
```
