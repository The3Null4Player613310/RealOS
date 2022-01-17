output_init:
jmp output_end
output_clear:
	push ax
	mov ax, 0x0013
	int 10h
	pop ax
	jmp output_return
output_print_char:		; uses al to print ascii char
	push bx
	mov ah, 0x0E
	mov bh, 0x01
	mov bl, 0x0A
	int 10h
	pop bx
	jmp output_return
output_print_newline:		; prints newline
	push ax
	mov al, 0x0A
	call output_print_char
	mov al, 0x0D
	call output_print_char
	pop ax
	jmp output_return
output_print_backspace:		; prints backspace
	push ax
	mov al, 0x08
	call output_print_char
	mov al, 0x20
	call output_print_char
	mov al, 0x08
	call output_print_char
	pop ax
	jmp output_return
output_print_string:		; uses si to print null terminated string
	lodsb
	or al, al
	jz output_return
	call output_print_char
	jmp output_print_string
output_print_string_ln:		; uses si to print null terminated string with new line
	call output_print_string
	call output_print_newline
	jmp output_return
output_return:
	ret
output_end:
