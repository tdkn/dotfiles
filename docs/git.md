# Git

## Shared configuration

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

## Signing

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
