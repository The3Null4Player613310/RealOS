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
string_copy:
	push si
	push di
	string_copy_loop:
		lodsb
		or al, al
		jz string_copy_terminate
		stosb
		jmp string_copy_loop
	string_copy_terminate:
		stosb
		pop di
		pop si
		jmp string_return
;string_compare:
;	push si
;	push di
;	string_compare_loop:
;		mov ax, [ds:si+bx]
;		sub ax, [ds:di+bx]
string_return:
	ret
string_end:	
