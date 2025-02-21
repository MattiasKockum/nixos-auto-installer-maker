.PHONY: iso disk

iso:
	nix flake update
	nix build .#GoodPracticeNixosConfigurations.iso.config.system.build.isoImage

disk:
	qemu-img create -f qcow2 nixos.qcow2 32G

run:
	qemu-system-x86_64 -enable-kvm -m 256 -cdrom result/iso/nixos-*.iso
