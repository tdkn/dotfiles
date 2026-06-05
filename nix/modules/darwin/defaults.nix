{ ... }:
{
  # macOS user defaults managed by nix-darwin. Add Finder, Dock, global domain,
  # and application defaults here as the workstation preferences grow.
  system.defaults = {
    finder = {
      AppleShowAllExtensions = true;
      FXPreferredViewStyle = "Nlsv";
      ShowPathbar = true;
      ShowStatusBar = true;
      _FXSortFoldersFirst = true;
    };
    dock = {
      autohide = true;
      mru-spaces = false;
      showhidden = true;
      showMissionControlGestureEnabled = true;
      showAppExposeGestureEnabled = true;
    };
    ".GlobalPreferences" = {
      "com.apple.mouse.scaling" = 2.0;
    };
    NSGlobalDomain = {
      InitialKeyRepeat = 15;
      KeyRepeat = 1;
      "com.apple.sound.beep.feedback" = 1;
    };
    trackpad = {
      Clicking = true;
      TrackpadRightClick = true;
      TrackpadThreeFingerDrag = true;
    };
    universalaccess = {
      closeViewScrollWheelToggle = true;
      mouseDriverCursorSize = 2.0;
    };
  };
}
