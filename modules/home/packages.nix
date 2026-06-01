{ pkgs, ... }:
{
  # Shared Home Manager package list for the tdkn profile. Keep this module as
  # the place for user-scoped Nix packages that do not warrant a dedicated
  # program module or a Homebrew entry.
  home.packages = with pkgs; [
    # Nix language servers used by editors such as Zed.
    nil
    nixd
  ];
}
