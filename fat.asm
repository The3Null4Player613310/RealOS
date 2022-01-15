fat_init:
jmp fat_end
msg_fat_error db "fat error",0
fat_load:
	mov al, 1
	mov cx, 0x0001	;cyl 0, sec 1
	mov dx, 0x0000	;hed 0, drv 0
	mov ah, 0x02
	int 13h
	jc fat_error
	jmp fat_return
fat_error:
	mov si, msg_fat_error
	call io_print_string_ln
	mov ah, 0x00
	int 13h
	jmp fat_return	
fat_return:
	ret
fat_end:
