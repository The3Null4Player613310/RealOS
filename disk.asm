disk_init:
	call disk_get_params	; get drive parameters
jmp disk_end
disk_get_sector:		; uses (cs) cx to get sector value
	mov ax, cx
	and ax, 0x003F
	sub ax, 0x01
	jmp disk_return
disk_get_cylindar:		; uses (cs) cx to get cylindar value
	mov ax, cx
	shr al, 0x06
	ror ax, 0x08
	jmp disk_return
disk_set_sector:		; uses (sector) ax, (cs) cx to set sector in cs
	push ax
	add ax, 0x01
	and ax, 0x003F
	and cx, 0xFFC0
	or cx, ax
	pop ax
	jmp disk_return
disk_set_cylindar:		; uses (cylindar) ax, (cs) cx to set cylindar in cs
	push ax
	shl ah, 0x06
	ror ax, 0x08
	and ax, 0xFFC0
	and cx, 0x003F
	or cx, ax
	pop ax
	jmp disk_return
disk_get_params:		; get primary disk params
	push es
	mov dl, [addr_svs_pdv]
	mov ah, 0x08
	int 13h

	shr dx, 0x08		; set total head count
	inc dx
	mov [addr_svs_thc], dx
	
	call disk_get_sector	; set sectors per track
	inc ax
	mov [addr_svs_spt], ax

	call disk_get_cylindar	; set tracks per head
	inc ax			; here
	mov [addr_svs_tph], ax
	
	mov bx, 0x0003		; set bytes per sector
	xor ah, ah
	mov cl, [es:di+bx]	; why 0x00F0

	mov bx, 0x0080
	shl bx, cl
	mov bx, 0x0200		; hardcoded value
	mov [addr_svs_bps], bx

	pop es
	jmp disk_return
;disk_set_chs:			; uses (sector) ax to set chs address
;	push bx
;	push ax
;	mov cx, [addr_svs_spt]
;	xor dx, dx
;	div cx
;	;inc dx
;	pop cx
;	push dx			; here
;	push cx
;	mov cx, [addr_svs_thc]
;	xor dx, dx
;	div cx
;	pop cx
;	push dx
;	push cx
;	mov ax, [addr_svs_spt]
;	mov cx, [addr_svs_thc]
;	mul cx
;	mov cx, ax
;	pop ax
;	xor dx, dx
;	div cx
;	push ax	
;	pop ax
;	call disk_set_cylindar
;	pop dx
;	shl dx, 0x08
;	;mov dh, dl
;	;xor dl, dl
;	pop ax
;	call disk_set_sector
;	pop bx
;	jmp disk_return
;disk_set_chs:
;	push ax
;	mov ax, [addr_svs_thc]	; 16 or 0x10
;	mov bx, [addr_svs_spt]	; 63 or 0x3F
;	mul bx
;
;	mov bx, ax
;	pop ax
;	xor dx,dx
;	div bx			; ax / 0x0630
;
;	push dx
;
;	call disk_set_cylindar
;
;	mov bx, [addr_svs_spt]	; 63 or 0x3F
;	pop ax
;	xor dx,dx
;	div bx
;
;	push  ax
;
;	mov ax,dx
;	call disk_set_sector
;
;	pop dx
;	shl dx, 0x08
;	
;	jmp disk_return
disk_set_chs:
	push bx
	push ax

	mov bx, [addr_svs_spt]
	xor dx, dx
	div bx

	push dx

	mov ax, [addr_svs_spt]
	mov bx, [addr_svs_thc]
	mul bx

	mov bx, ax
	pop dx
	pop ax
	push dx
	xor dx, dx
	div bx

	push ax

	mov ax, dx
	mov bx, [addr_svs_spt]
	xor dx, dx
	div bx

	mov dx, ax		; head
	shl dx, 0x08

	pop ax			; track
	call disk_set_cylindar

	pop ax			; sector
	call disk_set_sector

	pop bx	
	jmp disk_return
disk_get_sec:
	push dx
	
	call disk_get_cylindar
	mov bx, [addr_svs_thc]
	mul bx

	pop dx
	push dx

	mov bx, dx
	shr bx, 0x08
	add ax, bx

	mov bx, [addr_svs_spt]
	mul bx
	mov bx, ax

	call disk_get_sector
	add ax, bx
	pop dx	
	jmp disk_return
disk_load_sec:			; uses (buffer) es, (offset) bx, (cs) cx, and (head) dh to write to ram from disk
	mov ah, 0x03
	push ax
	disk_load_sec_loop:
		pop ax
		push ax
		mov dl, [addr_svs_pdv]	; drv 0
		mov ax, 0x0201	; load one sector to ram
		int 13h		; problem child
		jc disk_load_sec_error
		mov al, 'S'
		call put_char
		pop ax
		jmp disk_return
	disk_load_sec_error:
		mov al, 'E'
		call put_char
		;mov si, msg_error
		;call output_print_string_ln
		mov ah, 0x00	; reset disk subsystem
		int 13h
		pop ax
		dec ah
		or ah, ah
		jz disk_return
		push ax
		jmp disk_load_sec_loop
disk_load:			; uses (offset) bx, (sector) ax, (count) cx
	cmp cx, 0x0000
	je disk_return
	push ax
	push bx
	push cx
	call disk_set_chs
	call disk_load_sec
	pop cx
	pop bx
	pop ax
	dec cx
	inc ax
	add bx, [addr_svs_bps]
	jmp disk_load
disk_return:
	ret
disk_end:
