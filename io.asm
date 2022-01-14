io_init:
jmp io_end
io_print_char:		;uses al to print ascii char
	mov ah, 0x0E
	mov bh, 0x01
	int 10h
	jmp io_return
io_print_string:	;uses si to print null terminated string
	lodsb
	or al, al
	jz io_return
	call io_print_char
	jmp io_print_string
io_return:
	ret
io_end:
