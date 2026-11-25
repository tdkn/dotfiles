# Tailscale

On Apple Silicon and Intel, mise installs the Standalone app from the
`tailscale-app` cask. Tailscale requires macOS 13 or later.

## Setup

1. Run the [bootstrap](../README.md#quick-start) on each Mac. The
   package installer requires administrator authentication.
2. Open Tailscale and allow the VPN configuration and the system extension,
   following the prompts in System Settings. The `tailscale` command needs
   the extension to connect. Sign in to the same tailnet and approve the
   devices in the admin console if needed.
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
