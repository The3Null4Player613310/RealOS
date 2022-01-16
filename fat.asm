fat_init:
jmp fat_end
fat_load:		; uses es and bx to write to ram from disk
	push es
	mov ax, 0x0003
	push ax
	fat_load_loop:
		;mov bx, 0x07A0 ; boot sector 0x07c0
		;push bx
		;pop es
		mov bx, 0x7A00	; offset to end of boot sector
		mov al, 0x01	; sec c
		mov cx, 0x0002	; cyl 0, sec 2
		mov dh, 0x00	; hed 0
		mov dl, [drive]	; drv 0
		mov ah, 0x02	; load sector to ram
		int 13h
		jc fat_load_error
		pop ax
		pop es
		jmp fat_return
	fat_load_error:
		mov si, msg_error
		call io_print_string_ln
		mov ah, 0x00	; reset disk subsystem
		int 13h
		pop ax
		dec al
		or al, al
		jz fat_return
		push ax
		jmp fat_load_loop	
fat_return:
	ret
fat_end:
