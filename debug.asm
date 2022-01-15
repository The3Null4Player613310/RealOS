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
	call io_print_newline	
	jmp debug_return
debug_print_hex_nibble:
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
debug_return:
	ret
debug_end:
