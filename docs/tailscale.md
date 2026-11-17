# Tailscale

The bootstrap installs the Standalone app through Homebrew on Apple Silicon
and mise's `brew-cask` manager on Intel. Tailscale requires macOS 13 or later.

## Setup

1. Run the [bootstrap](../README.md#quick-start) on each Mac. The Intel
   package installer requires administrator authentication.
2. Open Tailscale and allow the VPN configuration and the system extension,
   which is approved in System Settings > Privacy & Security.
   `tailscale` commands hang until it is allowed. Sign in to the same
   tailnet and approve the devices in the admin console if needed.
3. Enable MagicDNS and give each device a distinct name. The package
   installer adds the `tailscale` command; if it is missing, install the
   command line integration from Tailscale Settings. Check connectivity
   with `<peer>` replaced by the other device's name:

   ```sh
   tailscale status
   tailscale ping <peer>
   ```

See the [macOS installation guide](https://tailscale.com/docs/install/mac).
Do not run the App Store and Standalone variants together; follow the
[migration instructions](https://tailscale.com/docs/concepts/macos-variants)
when switching variants.

## Availability

A sleeping or powered-off Mac cannot receive connections. The Standalone app
does not run before login, so test restart, FileVault, and sleep behavior before
relying on remote access. The app updates itself. `tailscale ping` and
`tailscale status` show whether a connection is direct or relayed; a relay is
encrypted but may be slower.
