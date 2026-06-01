{ ... }:
{
  # macOS user defaults managed by nix-darwin. Add Finder, Dock, global domain,
  # and application defaults here as the workstation preferences grow.
  system.defaults = {
    finder = {
      FXPreferredViewStyle = "Nlsv";
    };
  };
}
