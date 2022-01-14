CC=gcc
AC=fasm

.PHONY: build clean qemu

build: boot.bin filesystem.bin disk.iso

boot.bin:
	$(AC) boot.asm

filesystem.bin:
	dd if=/dev/zero of=./filesystem.bin bs=512 count=2047
	mkfs.vfat -F 12 ./filesystem.bin

disk.iso: boot.bin filesystem.bin
	dd if=/dev/zero of=./disk.iso bs=512 count=2048
	dd if=./boot.bin of=./disk.iso conv=notrunc
	dd if=./filesystem.bin of=./disk.iso conv=notrunc bs=512 seek=1

qemu: build 
	qemu-system-i386 ./disk.iso

clean:
	rm ./boot.bin
	rm ./filesystem.bin
	rm ./disk.iso
