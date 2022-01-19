CC=gcc
AC=fasm
LD=$(shell losetup -f 2>&1 | grep loop)

.PHONY: build clean qemu

build: boot.bin filesystem.bin REAL.OS disk.iso

boot.bin:
	$(AC) boot.asm

filesystem.bin:
	dd if=/dev/zero of=./filesystem.bin bs=512 count=2047
	mkfs.vfat -F 12 ./filesystem.bin

REAL.OS:
	$(AC) real.asm
	mv ./real.bin ./REAL.OS

disk.iso: boot.bin filesystem.bin REAL.OS
	dd if=/dev/zero of=./disk.iso bs=512 count=2048
	dd if=./boot.bin of=./disk.iso conv=notrunc
	dd if=./filesystem.bin of=./disk.iso conv=notrunc bs=512 seek=1
	losetup -P $(LD) ./disk.iso
	mount $(LD)p1 /mnt
	cp ./REAL.OS /mnt/REAL.OS
	sync
	umount /mnt
	sync
	losetup -d $(LD)

qemu: build 
	qemu-system-i386 ./disk.iso

clean:
	rm ./boot.bin
	rm ./filesystem.bin
	rm ./REAL.OS
	rm ./disk.iso
