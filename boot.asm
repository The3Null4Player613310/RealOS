use16
org 0x7C00

;include "foo.asm"
include "sysvars.asm"
include "fatvars.asm"
;include "io.asm"

boot_init:

	mov ax, 0x8000		; set up stack
	mov ss, ax
	mov sp, 0x0000

	push ds			; sync segments for variables
	push es
	push cs
	push cs
	pop es
	pop ds
	
	mov [addr_svs_pdv], dl	; mov current drive to memory

	include "put.asm"
	include "disk.asm"

	;mov bx, 0x7E00		; emergency boot
	;mov cx, 0x0002
	;mov dh, 0x00
	;call disk_load_sec

	mov ax, 0x0001
	mov bx, 0x7E00
	mov cx, 0x0003
	call disk_load

	call boot_libs

	;mov ax, [addr_svs_thc]
	;call debug_print_hex_word
	;mov ax, [addr_svs_tph]
	;call debug_print_hex_word
	;mov ax, [addr_svs_spt]
	;call debug_print_hex_word
	
	;xor ax, ax
	;mov ax, 0x0035
	;test_loop:
	;	call debug_print_hex_word
	;	push ax
	;	call disk_set_chs
	;	call debug_print_hex_word
	;	mov al, dh
	;	call debug_print_hex_word
	;	call disk_get_sec
	;	call debug_print_hex_word
	;	call output_print_newline
	;	pop ax
	;	inc ax
	;	cmp al, 0x45
	;	jne test_loop

	;call load_vbr		; load volume boot record
	
	;call fat_load_fat	; load file allocation table

	;call load_root		; load root dir	

	;push cs		; get code segment offset
	;pop ax
	;call debug_print_hex_word

	;mov ax, 0x40
	;call disk_set_chs
	;mov ax, cx
	;call debug_print_hex_word
	;mov ax, dx
	;call debug_print_hex_word

	;push cs
	;pop ds

	;mov ax, [addr_svs_spt]
	;call debug_print_hex_word

	;mov ax, 0x0500		; lower bound of dump
	;mov bx, 0x0600		; upper bound of dump
	;call debug_dump

	mov si, msg_logo	; print logo
	call output_print_string_ln
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
	mov al, 'H'
	call put_char
	hlt

msg_logo db "RealOS",0		;10,13,0
msg_error db "ER",0		;10,13,0
command db "        ",0
;drive db 0x7F

times 446-($-$$) db 0		; boot v3
p1_boot_flag	db 0x80		; boot flag
p1_start_head	db 0x00		; head
p1_start_cs	dw 0x0005	; cyl / sec
p1_part_type	db 0x01		; fat 12
p1_end_head	db 0x20		; head
p1_end_cs	dw 0x0020	; cyl / sec
p1_lba_low	dw 0x0004	; lba
p1_lba_high	dw 0x0000	; lba
p1_blk_low	dw 0x07FE	; blocks
p1_blk_high	dw 0x0000	; blocks
times 510-($-$$) db 0		; mbr partition
dw 0xAA55			; magic word

;PART 2
boot_libs:
	include "output.asm"
	include "input.asm"
	;include "string.asm"
	include "fat.asm"
	;include "load.asm"
	include "debug.asm"
	ret
times (4*512)-($-$$) db 0	; storage
