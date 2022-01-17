use16
org 0x7c00

;include "foo.asm"
include "output.asm"
include "input.asm"
;include "io.asm"
include "fat.asm"
include "debug.asm"

boot_init:
	push ds			; sync segments for variables
	push es
	push cs
	push cs
	pop es
	pop ds
	
	mov [drive], dl		; mov current drive to memory

	call output_clear		; set graphics mode

	call fat_load_vbr	; load volume boot record
	
	call fat_load_root	; load root dir	

	;push cs		; get code segment offset
	;pop ax
	;call debug_print_hex_word

	push cs
	pop ds

	;mov ax, 0x7A00		; lower bound of dump
	;mov bx, 0x7B00		; upper bound of dump
	;call debug_dump

	mov si, msg_logo	; print logo
	call output_print_string
boot_loop:
	;call input_get_char
	mov al, '>'
	call output_print_char
	mov di, command
	call input_get_string
	mov si, command
	call output_print_string_ln
	jmp boot_loop
boot_exit:
	hlt

msg_logo db "RealOS",10,13,0
msg_error db "ERROR",10,13,0
drive db 0x7F
command db 0
times 1 db 0			; 63

times 446-($-$$) db 0		; boot v3
p1_boot_flag	db 0x80		; boot flag
p1_start_head	db 0x00		; head
p1_start_cs	dw 0x0002	; cyl / sec
p1_part_type	db 0x01		; fat 12
p1_end_head	db 0x20		; head
p1_end_cs	dw 0x0020	; cyl / sec
p1_lba_low	dw 0x0001	; lba
p1_lba_high	dw 0x0000	; lba
p1_blk_low	dw 0x07FF	; blocks
p1_blk_high	dw 0x0000	; blocks
times 510-($-$$) db 0		; mbr partition
dw 0xAA55			; magic word
times (1024*1024)-($-$$) db 0	; storage
