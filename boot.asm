use16
org 0x7c00

;include foo.asm

boot_init:
boot_loop:
	jmp boot_loop
