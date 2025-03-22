{
  description = "NixOS Auto installer maker";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    disko.url = "github:nix-community/disko";
  };

  outputs = { nixpkgs, disko, ... }:
  let
    system = "x86_64-linux";
  in {
    nixosConfigurations.autoInstaller = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        ({ ... }: {
          imports = [
            "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
            disko.nixosModules.disko
          ];
          isoImage.squashfsCompression = "gzip -Xcompression-level 1";
          system.activationScripts.copy-nixos-files.text = ''
            mkdir -p /etc/premade-configuration
            cp -r ${./nixos}/* /etc/premade-configuration/
          '';
        })
        ./iso.nix
      ];
    };
  };
}
