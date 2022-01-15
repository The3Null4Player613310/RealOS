string_init:
jmp string_end
string_length:
	push si
	push cx
	xor cx, cx
	string_length_loop:
		lodsb
		or al, al
		jz string_length_terminate
		inc cx
		jmp string_length_loop
	string_length_terminate:
		mov ax, cx
		pop cx
		pop si
		jmp string_return
string_return:
	ret
string_end:	
