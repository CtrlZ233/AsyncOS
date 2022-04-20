run:build qemu


debug:build debug-release run-gdb

build:
	cd os && cargo build

debug-release:
	qemu-system-riscv64 \
	-machine virt \
	-smp cpus=4  \
	-nographic -bios bootloader/rustsbi-qemu.bin \
	-device loader,file=os/target/riscv64gc-unknown-none-elf/debug/os,addr=0x80200000 \
	-device loader,file=basic_rt/target/riscv64gc-unknown-none-elf/debug/basic_rt.bin,addr=0x87000000 \
	-drive file=user/target/riscv64gc-unknown-none-elf/release/fs.img,if=none,format=raw,id=x0 \
	-device virtio-blk-device,drive=x0,bus=virtio-mmio-bus.0 -s -S

run-gdb:
	cd os && riscv64-unknown-elf-gdb -x .\.gdbinit_debug