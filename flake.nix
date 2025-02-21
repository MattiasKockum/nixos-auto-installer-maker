{
  description = "Good Practice NixOS";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    #disko.url = "github:nix-community/disko";
  };

  #outputs = { self, nixpkgs, disko }: {
  outputs = { self, nixpkgs }: {
    GoodPracticeNixosConfigurations = {
      iso = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ({ pkgs, modulesPath, ... }: {
            imports = [
              (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
              #disko.nixosModules.disko
              #./nixos
            ];
            isoImage.squashfsCompression = "gzip -Xcompression-level 1";

            system.activationScripts.copy-nixos-files.text = ''
              mkdir -p /etc/nixos
              cp -r ${./nixos}/* /etc/nixos/
            '';
          })
          ./iso.nix
        ];
      };
    };
  };
}
