{
	description = "Nixos configuration";

	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
	};

	outputs = { nixpkgs, ... } @ inputs:
  let
    lib = nixpkgs.lib;
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
  in {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        ./system/configuration.nix
      ];
    };
  };
}

