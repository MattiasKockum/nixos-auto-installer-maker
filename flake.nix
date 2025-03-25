{
  description = "NixOS Auto installer maker";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    disko.url = "github:nix-community/disko";
    configFlake.url = "github:MattiasKockum/nixos-auto-installer-maker?dir=exemples/basic_vm_config";
  };

  outputs = { self, nixpkgs, disko, configFlake, ... }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };

    mkInstaller = name: extraModules: nixpkgs.lib.nixosSystem {
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
            cp -r ${configFlake}/* /etc/premade-configuration/
          '';
        })
      ] ++ extraModules;
    };

  in {
    nixosConfigurations.autoInstallerFlakeSerial =
      mkInstaller "serial" [
        ./iso/general-config.nix
        ./iso/serial-config.nix
        ./iso/auto-install-flake-service.nix
      ];

    nixosConfigurations.autoInstallerFlakeVGA =
      mkInstaller "vga" [
        ./iso/general-config.nix
        ./iso/auto-install-flake-service.nix
      ];

    defaultPackage = {
	${system} = self.nixosConfigurations.autoInstallerFlakeSerial.config.system.build.isoImage;
    };
  };
}
