{ pkgs, ... }:
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.systemPackages = with pkgs; [
    disko
    neovim
    nixos-install-tools
  ];
}

