{
  description = "Good Practice NixOS";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  outputs = { self, nixpkgs }: {
    GoodPracticeNixosConfigurations = {
      iso = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ({ pkgs, modulesPath, ... }: {
            imports = [ (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix") ];
            isoImage.squashfsCompression = "gzip -Xcompression-level 1";
          })
          ./iso.nix
        ];
      };
    };
  };
}
