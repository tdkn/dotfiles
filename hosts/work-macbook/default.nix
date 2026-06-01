{
  inputs,
  pkgs,
  ...
}:
{
  # Host module for the work MacBook. It composes shared Darwin modules,
  # Home Manager, and the machine-specific macOS settings.
  imports = [
    # Shared Homebrew package declarations for macOS tools and applications.
    ../../modules/darwin/homebrew.nix
    # Shared macOS defaults for Finder and other system applications.
    ../../modules/darwin/defaults.nix
    # Home Manager is loaded as a nix-darwin module so user configuration is
    # applied during the same `darwin-rebuild` activation.
    inputs.home-manager.darwinModules.home-manager
  ];

  # Use Lix as the Nix implementation and enable the modern CLI features that
  # this flake-based configuration depends on.
  nix = {
    package = pkgs.lix;
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  # Pin nixpkgs evaluation to Apple Silicon macOS and allow unfree packages for
  # the casks and tools that require them in this personal workstation setup.
  nixpkgs = {
    hostPlatform = "aarch64-darwin";
    config.allowUnfree = true;
  };

  # Keep all macOS-visible host names aligned so sharing, networking, and shell
  # prompts refer to the machine consistently.
  networking = {
    computerName = "work-macbook";
    hostName = "work-macbook";
    localHostName = "work-macbook";
  };

  # nix-darwin state version gates compatibility defaults. Bump it only after
  # reviewing the release notes for changed macOS module behavior.
  system = {
    primaryUser = "tdkn";
    stateVersion = 6;
  };

  # Enable zsh at the system level; user-level shell behavior is configured in
  # the Home Manager profile below.
  programs.zsh.enable = true;

  # Declare the macOS user record that Home Manager targets.
  users.users.tdkn = {
    home = "/Users/tdkn";
  };

  # Integrate Home Manager with the same nixpkgs package set as nix-darwin and
  # pass flake inputs through to the user profile for future module imports.
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    users.tdkn = import ../../home/tdkn;
  };
}
