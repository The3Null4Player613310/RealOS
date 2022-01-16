debug_init:
jmp debug_end
debug_print_hex_word:	; uses ax to print a hex word
	rol ax, 4
	call debug_print_hex_nibble
	rol ax, 4
	call debug_print_hex_nibble
	rol ax, 4
	call debug_print_hex_nibble
	rol ax, 4
	call debug_print_hex_nibble	
	jmp debug_return
debug_print_hex_nibble:	; uses ax to print a hex nibble
	push ax
	and ax, 0x000F
	cmp ax, 9
	ja debug_print_hex_nibble_alpha
	debug_print_hex_nibble_num:
		add ax, 0x30
		jmp debug_print_hex_nibble_terminate
	debug_print_hex_nibble_alpha:
		sub ax, 0x0A
		add ax, 0x41
		jmp debug_print_hex_nibble_terminate
	debug_print_hex_nibble_terminate:
		call io_print_char
		pop ax
		jmp debug_return
debug_dump:		; uses ax and bx as lower bound and upper bound for dump
	push ax
	mov si, ax
	debug_dump_loop:
		lodsw
		call debug_print_hex_word
		mov al, ' '
		call io_print_char
		mov ax, si
		cmp ax, bx
		jb debug_dump_loop
		pop ax
		jmp debug_return
debug_return:
	ret
debug_end:
