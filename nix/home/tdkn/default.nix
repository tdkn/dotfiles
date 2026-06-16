{ config, ... }:
let
  dotfilesRoot = "${config.home.homeDirectory}/ghq/github.com/tdkn/dotfiles";
in
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
    # Keep Git's primary global config in ~/.gitconfig so `git config --global`
    # reads the same managed file that normal Git operations use.
    file = {
      ".codex/AGENTS.md" = {
        source = config.lib.file.mkOutOfStoreSymlink "${dotfilesRoot}/codex/AGENTS.md";
        force = true;
      };
      ".gitconfig" = {
        source = config.lib.file.mkOutOfStoreSymlink "${dotfilesRoot}/git/config";
        force = true;
      };
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

    profileExtra = builtins.readFile ../../../zsh/profile.zsh;

    initContent =
      (builtins.readFile ../../../zsh/init.zsh) + "\n" + (builtins.readFile ../../../zsh/ghq-clone.zsh);
  };

  # App configs stay writable through symlinks instead of being copied into the Nix store.
  xdg.configFile = {
    "git/ignore".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesRoot}/git/ignore";
    "ghostty/config.ghostty".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfilesRoot}/ghostty/config.ghostty";
    "karabiner/karabiner.json" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfilesRoot}/karabiner/karabiner.json";
      force = true;
    };
  };
}
