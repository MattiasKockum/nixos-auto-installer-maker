{
  description = "NixOS Auto installer maker";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    disko.url = "github:nix-community/disko";
  };

  outputs = { self, nixpkgs, disko, ... }@inputs: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      overlays = [];
    };
  in {
    # The iso build output
    packages.${system}.isoImage = self.nixosConfigurations.autoInstaller.config.system.build.isoImage;

    # A wrapper script to build + optionally run ISO
    apps.${system}.default = {
      type = "app";
      program = toString (pkgs.writeShellScript "auto-install-cli" ''
        set -euo pipefail

        # Use nix build to build the ISO
        nix build .#packages.${system}.isoImage

        echo "ISO built at ./result/iso/"
      '');
    };

    defaultApp.${system} = self.apps.${system}.default;

    # Define the NixOS configuration
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
