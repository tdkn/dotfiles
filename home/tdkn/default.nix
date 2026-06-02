{ ... }:
{
  # Home Manager profile for the tdkn macOS user. This file collects shell,
  # session, and dotfile settings that should follow the user account.
  imports = [
    # Shared user package list. It is kept separate so package growth does not
    # crowd the main profile settings.
    ../../modules/home/packages.nix
  ];

  # User identity and Home Manager compatibility baseline. The state version
  # should only change after intentionally adopting new Home Manager defaults.
  home = {
    username = "tdkn";
    homeDirectory = "/Users/tdkn";
    stateVersion = "26.05";
    # Default interactive tools exported to login shells and child processes.
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      PAGER = "less";
    };
  };

  # Let Home Manager manage its own generation metadata for this profile.
  programs.home-manager.enable = true;

  # Interactive zsh configuration for the user account. System-level zsh enablement
  # lives in the nix-darwin host module.
  programs.zsh = {
    enable = true;
    enableCompletion = true;

    # Shortcuts for the common flake maintenance commands and a familiar ls view.
    shellAliases = {
      darwin-build = "sudo darwin-rebuild build --flake ~/ghq/github.com/tdkn/dotfiles#work-macbook";
      darwin-switch = "sudo darwin-rebuild switch --flake ~/ghq/github.com/tdkn/dotfiles#work-macbook";
      darwin-update = "nix flake update --flake ~/ghq/github.com/tdkn/dotfiles";
      ghqc = "ghq-clone";
      ll = "ls -la";
    };

    profileExtra = builtins.readFile ./zsh/profile.zsh;

    initContent = (builtins.readFile ./zsh/init.zsh) + "\n" + (builtins.readFile ./zsh/ghq-clone.zsh);
  };

  # Link the raw Git configuration file into the home directory.
  home.file.".gitconfig".source = ./.gitconfig;
}
