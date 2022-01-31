string_init:
jmp string_end
string_length:		; returns (length) ax of (string) si
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
string_copy:		; copies (string) si to (string) di
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
string_compare:		; compares (string) si to (string) di returns 0 in (result) ax if equal
	push si
	push di
	string_compare_loop:
		mov ah, [ds:si]
		mov al, [ds:di]
		inc si
		inc di
		cmp ax, 0x0000
		je string_compare_equal
		cmp ah, al
		je string_compare_loop
		jmp string_compare_inequal
	string_compare_equal:
		mov ax, 0x0000
		jmp string_compare_terminate
	string_compare_inequal:
		mov ax, 0x0001
		jmp string_compare_terminate
	string_compare_terminate:
		pop di
		pop si
		jmp string_return
string_split:		; splits (string) si into (string) di (string) si at first occurance of (char) al
	mov di, si
	string_split_loop:
		mov ah, [ds:si]
		cmp ah, al
		je string_split_split
		inc si
		cmp ah, 0x00
		je string_split_unify
		jmp string_split_loop
	string_split_split:
		mov ah, 0x00
		mov [ds:si], ah
		jmp string_split_terminate
	string_split_unify:
		mov si, di
		jmp string_split_terminate
	string_split_terminate:
		jmp string_return  
string_return:
	ret
string_end:	
