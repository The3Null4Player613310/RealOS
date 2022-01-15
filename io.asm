io_init:
jmp io_end
io_print_char:		;uses al to print ascii char
	mov ah, 0x0E
	mov bh, 0x01
	mov bl, 0x0A
	int 10h
	jmp io_return
io_print_newline:	;prints newline
	push ax
	mov al, 0x0A
	call io_print_char
	mov al, 0x0D
	call io_print_char
	pop ax
	jmp io_return
io_print_backspace:	;prints backspace
	push ax
	mov al, 0x08
	call io_print_char
	mov al, 0x20
	call io_print_char
	mov al, 0x08
	call io_print_char
	pop ax
	jmp io_return
io_print_string:	;uses si to print null terminated string
	lodsb
	or al, al
	jz io_return
	call io_print_char
	jmp io_print_string
io_print_string_ln:	;uses si to print null terminated string with new line
	call io_print_string
	call io_print_newline
io_get_key:
	xor al, al
	mov ah, 0x01
	int 16h
	jz io_return
	mov ah, 0x00
	int 16h
	io_get_key_alpha:
		cmp al, 0x61 ; lower bound alpha
		jb io_get_key_num
		cmp al, 0x7A ; upper bound alpha
		ja io_get_key_num
		sub al, 0x20 ; ascii alpha offset
		jmp io_return
	io_get_key_num:
		cmp al, 0x2F ; lower bound num
		jb io_get_key_other
		cmp al, 0x3A ; upper bound num
		ja io_get_key_other
		sub al, 0x00 ; ascii num offset
		jmp io_return
	io_get_key_other:
		jmp io_return
io_get_char:		;gets ascii character
	call io_get_key
	cmp al, 0x00
	je io_get_char
	jmp io_return
io_get_string:
	push di
	push cx
	xor cx, cx
	io_get_string_loop:
		call io_get_char
		cmp al, 0x08
		je io_get_string_backspace
		cmp al, 0x0D
		je io_get_string_terminate
		inc cl
		stosb
		call io_print_char
		jmp io_get_string_loop
	io_get_string_backspace:
		or cl, cl
		jz io_get_string_loop
		dec cl
		dec di
		call io_print_backspace
		jmp io_get_string_loop
	io_get_string_terminate:
		mov al, 0x00
		stosb
		call io_print_newline
		pop cx
		pop di
		jmp io_return
io_return:
	ret
io_end:
