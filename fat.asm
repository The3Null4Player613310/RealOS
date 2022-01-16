fat_init:
jmp fat_end
fat_load:		; uses (buffer) es, (count) al, (offset) bx, (cs) cx, and (head) dh to write to ram from disk
	mov ah, 0x03
	push ax
	fat_load_loop:
		;mov bx, 0x07A0 ; boot sector 0x07c0
		;push bx
		;pop es
		pop ax
		push ax
		mov dl, [drive]	; drv 0
		mov ah, 0x02	; load sector to ram
		int 13h
		jc fat_load_error
		pop ax
		jmp fat_return
	fat_load_error:
		mov si, msg_error
		call io_print_string_ln
		mov ah, 0x00	; reset disk subsystem
		int 13h
		pop ax
		dec ah
		or ah, ah
		jz fat_return
		push ax
		jmp fat_load_loop
fat_load_vbr:
	push bx
	push cx
	push dx
	mov al, 0x01		; sector count
	mov bx, 0x7800		; offset to end of boot sector
	mov cx, [p1_start_cs]	; cyl 0, sec 2
	mov dh, [p1_start_head]	; hed 0
	call fat_load
	pop dx
	pop cx
	pop bx
	jmp fat_return	
fat_return:
	ret
fat_end:
