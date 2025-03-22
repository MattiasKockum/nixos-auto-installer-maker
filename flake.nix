{
  description = "NixOS Auto installer maker";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    disko.url   = "github:nix-community/disko";
    # The default configuration directory is the Git-tracked ./nixos.
    # If you want to override it, the external directory must have a flake.nix.
    configPath.url = "path:./nixos";
  };

  outputs = { self, nixpkgs, disko, configPath, ... }:
  let
    system = "x86_64-linux";
    pkgs   = import nixpkgs { inherit system; };

    # Stage the config directory from the configPath input.
    # If the input comes from an external flake, it should have a "files" attribute
    # (or you can adjust this to suit your external flake).
    stagedConfig =
      if builtins.pathExists configPath then
        # We assume the external flake is a directory with a flake.nix.
        # Here we simply use configPath itself (or you could extract a file set).
        configPath
      else
        ./nixos;
  in {
    # Define the NixOS configuration.
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
            cp -r ${stagedConfig}/* /etc/premade-configuration/
          '';
        })
        ./iso.nix
      ];
    };

    # Build the ISO image.
    packages.${system}.isoImage =
      self.nixosConfigurations.autoInstaller.config.system.build.isoImage;

    # Set the default package so that "nix build" picks it up.
    defaultPackage.${system} = self.packages.${system}.isoImage;
  };
}

