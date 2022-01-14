use16
org 0x7c00

;include foo.asm

boot_init:
boot_loop:
	jmp boot_loop
boot_exit:
	hlt

times 446-($-$$) db 0		;boot v1
dw 0x0080			;boot flag
dw 0x0002
dw 0x2001			;fat 12
dw 0x0020
dw 0x0001
dw 0x0000
dw 0x07FF
times 510-($-$$) db 0		;mbr partition
dw 0xAA55			;magic word
times (1024*1024)-($-$$) db 0	;storage