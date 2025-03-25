# Nixos Auto Installer Maker

This project aims at creating an ISO installer that automatically installs a given flake.
The flake must have a disko.nix at its root.

## Disclaimer
This project is ongoing and far from finished. A lot can be done to improve it and we would love some feedback and pull requests.

## Examples
By default it creates an ISO image based on the basic_vm_config inside of exemples. (Serial installer)
```sh
nix build github:MattiasKockum/nixos-auto-installer-maker
```

To create an ISO based on another flake. (VGA installer)
```sh
nix build github:MattiasKockum/nixos-auto-installer-maker#nixosConfigurations.autoInstallerFlakeVGA.config.system.build.isoImage --override-input configFlake "github:MattiasKockum/nixos-auto-installer-maker?dir=exemples/basic_vm_config"
```

## Note
A little Makefile is available to help starting with the project and test the images created with it.

