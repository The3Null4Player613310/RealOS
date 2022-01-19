put_init:
jmp put_end
put_char:		; uses al to print ascii char
	push ax
	push bx
	mov ah, 0x0E
	mov bh, 0x01
	mov bl, 0x0A
	int 10h
	pop bx
	pop ax
	jmp put_return
put_newline:		; prints newline
	push ax
	mov al, 0x0A
	call put_char
	mov al, 0x0D
	call put_char
	pop ax
	jmp put_return
put_return:
	ret
put_end:
