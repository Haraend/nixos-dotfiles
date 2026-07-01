{
  description = "NixOS + Home Manager flake (Niri, Noctalia, Stylix)";

  inputs = {
    # nixos-unstable — revision pinned in flake.lock (not rolling). Bump deliberately:
    #   nix flake update nixpkgs home-manager stylix
    # Do not run bare `nix flake update` (updates every input at once).
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nixos-hardware.url = "github:NixOS/nixos-hardware/ef4efb84766a166c906bd55759574676bf91267c";

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

    noctalia = {
      url = "github:noctalia-dev/noctalia/v4.7.7";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    antigravity-nix = {
      url = "github:jacopone/antigravity-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    vars = import ./lib/vars.nix;
  in
  {
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
