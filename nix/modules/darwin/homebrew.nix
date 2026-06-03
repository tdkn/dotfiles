{ ... }:
{
  # Homebrew covers macOS applications, casks, fonts, and formulae that are more
  # convenient to keep outside the Nix store on this workstation.
  homebrew = {
    enable = true;

    # Keep `darwin-rebuild switch` predictable: it installs declared packages but
    # does not update taps, upgrade formulae, or remove unmanaged packages.
    onActivation = {
      autoUpdate = false;
      cleanup = "none";
      upgrade = false;
    };

    # Command-line tools installed as Homebrew formulae. These are available
    # system-wide and complement the user-level Home Manager configuration.
    brews = [
      "act"
      "aria2"
      "bat"
      "coreutils"
      "deno"
      "dnsmasq"
      "fd"
      "fish"
      "fzf"
      "gh"
      "ghq"
      "git"
      "git-extras"
      "git-filter-repo"
      "htop"
      "jnv"
      "jq"
      "lazygit"
      "mas"
      "mise"
      "neovim"
      "ripgrep"
      "starship"
      "tmux"
      "tree"
      "xcbeautify"
      "xcdiff"
      "xcode-build-server"
    ];

    # GUI applications, fonts, and vendor-distributed tools managed by cask so a
    # fresh macOS install can be rebuilt from this single declarative list.
    casks = [
      "1password"
      "1password-cli"
      "apparency"
      "arc"
      "chatgpt"
      "claude"
      "claude-code"
      "codex-app"
      "cursor"
      "figma"
      "font-fira-code"
      "font-hack-nerd-font"
      "font-monaspace"
      "font-sauce-code-pro-nerd-font"
      "font-symbols-only-nerd-font"
      "ghostty"
      "gitbutler"
      "google-chrome"
      "google-japanese-ime"
      "jetbrains-toolbox"
      "karabiner-elements"
      "mac-mouse-fix"
      "notion"
      "obsidian"
      "ogdesign-eagle"
      "orbstack"
      "raindropio"
      "setapp"
      "sf-symbols"
      "spotify"
      "visual-studio-code"
      "xcodes-app"
      "yaak"
      "zed"
    ];
  };
}
