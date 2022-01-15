use16
org 0x7c00

;include "foo.asm"
include "io.asm"
include "fat.asm"
;include "debug.asm"

boot_init:
	push ds			;sync segments for variables
	push es
	push cs
	push cs
	pop es
	pop ds
	
	mov [drive], dl		; mov current drive to memory

	mov ax, 0x0013		; set graphics mode
	int 10h

	call fat_load
	
	;push cs		; get code segment offset
	;pop ax
	;call debug_print_hex_word

	mov si, msg_logo	; print logo
	call io_print_string
boot_loop:
	;call io_get_char
	mov al, '>'
	call io_print_char
	mov di, command
	call io_get_string
	mov si, command
	call io_print_string_ln
	jmp boot_loop
boot_exit:
	hlt

msg_logo db "RealOS",10,13,0
msg_error db "ERROR",10,13,0
drive db 0x7F
command db 0
times 63 db 0

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
