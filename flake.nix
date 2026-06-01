{
  # Entry point for the macOS dotfiles. The flake ties together nix-darwin,
  # Home Manager, and the repository modules into one reproducible host build.
  description = "A Nix-powered home for tdkn's dotfiles";

  inputs = {
    # Darwin-compatible nixpkgs branch used by both system and user packages.
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";

    # nix-darwin applies the system-level macOS configuration. It follows the
    # same nixpkgs input so package selection stays consistent across modules.
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Home Manager owns user-level configuration such as shell setup, files,
    # and per-user packages. It also follows nixpkgs for a single package set.
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nix-darwin,
      ...
    }:
    let
      # The only supported host is currently an Apple Silicon Mac.
      system = "aarch64-darwin";
    in
    {
      # Build target used by `darwin-rebuild --flake .#work-macbook`.
      # Host-specific configuration lives under hosts/work-macbook.
      darwinConfigurations."work-macbook" = nix-darwin.lib.darwinSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/work-macbook
        ];
      };

      # Expose the pinned formatter so `nix fmt` uses the same style everywhere.
      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-rfc-style;
    };
}
