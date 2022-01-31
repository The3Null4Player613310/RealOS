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
string_copy:		; copies a string from (string) si to (string) di
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
string_compare:
	push si
	push di
	string_compare_loop:
		mov ah, [ds:si+bx]
		mov al, [ds:di+bx]
		cmp ax, 0x0000
		je string_compare_equal
		cmp ah, al
		je string_compare_loop
		jmp string_compare_inequal
	string_compare_equal:
		mov ax, 0x0000
		jmp compare_terminate:
	string_compare_inequal:
		mov ax, 0x0001
		jmp compare_terminate:
	string_compare_terminate:
		pop di
		pop si
		jmp string_return
string_return:
	ret
string_end:	
