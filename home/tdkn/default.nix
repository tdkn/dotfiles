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
      ll = "ls -la";
    };

    # Import Homebrew's shell environment for login shells so formulae and casks
    # that expose commands under /opt/homebrew are available on PATH.
    profileExtra = ''
      if [ -x /opt/homebrew/bin/brew ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
      fi
    '';

    # Initialize optional command-line integrations only when the corresponding
    # tools are installed, keeping shell startup resilient across fresh machines.
    initContent = ''
      if command -v mise >/dev/null 2>&1; then
        eval "$(mise activate zsh)"
      fi

      if command -v starship >/dev/null 2>&1; then
        eval "$(starship init zsh)"
      fi

      if command -v fzf >/dev/null 2>&1; then
        source <(fzf --zsh)
      fi
    '';
  };

  # Link the raw Git configuration file into the home directory.
  home.file.".gitconfig".source = ./.gitconfig;
}
