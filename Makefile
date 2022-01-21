CC=gcc
AC=fasm
LD=$(shell losetup -f 2>&1 | grep loop)
BOOTSIZE=2
DISKSIZE=2048
PARTSIZE=$(shell expr $(DISKSIZE) - $(BOOTSIZE))

.PHONY: build clean qemu

build: boot.bin filesystem.bin REAL.OS disk.iso

boot.bin:
	$(AC) boot.asm

filesystem.bin:
	dd if=/dev/zero of=./filesystem.bin bs=512 count=$(PARTSIZE)
	mkfs.vfat -F 12 ./filesystem.bin

REAL.OS:
	$(AC) real.asm
	mv ./real.bin ./REAL.OS

disk.iso: boot.bin filesystem.bin REAL.OS
	dd if=/dev/zero of=./disk.iso bs=512 count=$(DISKSIZE)
	dd if=./boot.bin of=./disk.iso conv=notrunc bs=512 count=$(BOOTSIZE)
	dd if=./filesystem.bin of=./disk.iso conv=notrunc bs=512 seek=$(BOOTSIZE)
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
