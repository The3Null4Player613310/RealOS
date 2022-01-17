input_init:
jmp input_end
input_get_key:
	xor al, al
	mov ah, 0x01
	int 16h
	jz input_return
	mov ah, 0x00
	int 16h
	input_get_key_alpha:
		cmp al, 0x61	; lower bound alpha
		jb input_get_key_num
		cmp al, 0x7A 	; upper bound alpha
		ja input_get_key_num
		sub al, 0x20 	; ascii alpha offset
		jmp input_return
	input_get_key_num:
		cmp al, 0x2F 	; lower bound num
		jb input_get_key_other
		cmp al, 0x3A	; upper bound num
		ja input_get_key_other
		sub al, 0x00	; ascii num offset
		jmp input_return
	input_get_key_other:
		jmp input_return
input_get_char:			; gets ascii character
	call input_get_key
	cmp al, 0x00
	je input_get_char
	jmp input_return
input_get_string:
	push di
	push cx
	xor cx, cx
	input_get_string_loop:
		call input_get_char
		cmp al, 0x08
		je input_get_string_backspace
		cmp al, 0x0D
		je input_get_string_terminate
		inc cl
		stosb
		call output_print_char
		jmp input_get_string_loop
	input_get_string_backspace:
		or cl, cl
		jz input_get_string_loop
		dec cl
		dec di
		call output_print_backspace
		jmp input_get_string_loop
	input_get_string_terminate:
		mov al, 0x00
		stosb
		call output_print_newline
		pop cx
		pop di
		jmp input_return
input_return:
	ret
input_end:
