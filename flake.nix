{
  description = "NixOS + Home Manager flake (Niri, Noctalia, Stylix)";

  inputs = {
    # nixos-unstable — revision pinned in flake.lock (not rolling). Bump deliberately:
    #   nix flake update nixpkgs home-manager stylix nixos-hardware
    # Do not run bare `nix flake update` (updates every input at once).
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };

    # Pinned to v5.2.0. Bump deliberately and build-test first.
    # Do not follow nixpkgs: that changes the derivation hash and misses
    # noctalia.cachix.org. Their locked nixpkgs is a second copy in the store.
    noctalia = {
      url = "github:noctalia-dev/noctalia/v5.2.0";
    };

  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      # path: (not a bare git flake) so these gitignored files are visible.
      vars =
        if builtins.pathExists ./lib/vars.nix then
          import ./lib/vars.nix
        else
          throw ''
            Missing lib/vars.nix.
            Copy lib/vars.example.nix to lib/vars.nix and edit username, configPath, and timezone.
          '';
      hardwarePresent =
        if builtins.pathExists ./hosts/nixos/hardware-configuration.nix then
          true
        else
          throw ''
            Missing hosts/nixos/hardware-configuration.nix.
            Copy hosts/nixos/hardware-configuration.example.nix to hosts/nixos/hardware-configuration.nix, then regenerate it:
              sudo nixos-generate-config --show-hardware-config > hosts/nixos/hardware-configuration.nix
          '';
    in
    builtins.seq hardwarePresent {
      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs vars; };
          modules = [
            { nixpkgs.hostPlatform = system; }
            ./hosts/nixos/configuration.nix
            inputs.home-manager.nixosModules.default
            inputs.stylix.nixosModules.stylix
          ];
        };
      };

      formatter.${system} = pkgs.nixpkgs-fmt;
    };
}
