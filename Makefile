.PHONY: iso disk run

OVMF_CODE = $(shell find /nix/store -name "OVMF_CODE.fd" | head -n 1)
ISO_FILE = $(shell find result/iso -name "nixos-*.iso" | head -n 1)

iso:
	#nix build .#nixosConfigurations.autoInstallerFlakeVGA.config.system.build.isoImage
	nix build github:MattiasKockum/nixos-auto-installer-maker#nixosConfigurations.autoInstallerFlakeVGA.config.system.build.isoImage --override-input configFlake "github:MattiasKockum/nixos-auto-installer-maker?dir=exemples/basic_vm_config"

disk:
	qemu-img create -f qcow2 nixos.qcow2 32G

run:
	qemu-system-x86_64 -enable-kvm -m 4096 \
		-net user,hostfwd=tcp::2222-:22,hostfwd=tcp::8443-:443,hostfwd=tcp::8080-:80 -net nic \
		-drive if=pflash,format=raw,readonly=on,file=$(OVMF_CODE) \
		-drive file=nixos.qcow2,if=none,id=disk \
		-device virtio-blk-pci,drive=disk,bootindex=1 \
		-drive file=$(ISO_FILE),if=none,id=cdrom,media=cdrom \
		-device ide-cd,drive=cdrom,bootindex=2
