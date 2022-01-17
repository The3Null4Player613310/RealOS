addr_vbr = 0x7600		; 512 bytes ; volume boot record
addr_vbr_oem = addr_vbr + 0x03	; 008 bytes ; oem name
addr_vbr_bps = addr_vbr + 0x0B	; 002 bytes ; bytes per sector
addr_vbr_spc = addr_vbr + 0x0D	; 001 bytes ; sectors per cluster
addr_vbr_rsc = addr_vbr + 0x0E	; 002 bytes ; reserved sector count
addr_vbr_tfc = addr_vbr + 0x10	; 001 bytes ; total fat count
addr_vbr_mre = addr_vbr + 0x11	; 002 bytes ; max root entries
addr_vbr_tsc = addr_vbr + 0x13	; 002 bytes ; total sector count
addr_vbr_mdv = addr_vbr + 0x15	; 001 bytes ; media descriptor value
addr_vbr_spf = addr_vbr + 0x16	; 002 bytes ; sectors per fat
addr_vbr_spt = addr_vbr + 0x18	; 002 bytes ; sectors per track
addr_vbr_thc = addr_vbr + 0x1A	; 002 bytes ; total head count
addr_vbr_hsl = addr_vbr + 0x1C	; 004 bytes ; hidden sector count low
addr_vbr_hsh = addr_vbr + 0x1E	; 002 bytes ; hidden sector count high
addr_vbr_tsl = addr_vbr + 0x20	; 004 bytes ; total sector count low
addr_vbr_tsh = addr_vbr + 0x22	; 002 bytes ; total sector count high
addr_fat = addr_vbr + 0x0200	; var bytes ; root directory
fat_init:
jmp fat_end
fat_get_sector:		; uses (cs) cx to get sector value
	mov ax, cx
	and ax, 0x003F
	sub ax, 0x01
	jmp fat_return
fat_get_cylindar:	; uses (cs) cx to get cylindar value
	mov ax, cx
	shr al, 0x06
	ror ax, 0x08
	jmp fat_return
fat_set_sector:		; uses (sector) ax, (cs) cx to set sector in cs
	push ax
	add ax, 0x01
	and ax, 0x003F
	and cx, 0xFFC0
	or cx, ax
	pop ax
	jmp fat_return
fat_set_cylindar:	; uses (cylindar) ax, (cs) cx to set cylindar in cs
	push ax
	shl ah, 0x06
	ror ax, 0x08
	and ax, 0xFFC0
	and cx, 0x003F
	or cx, ax
	pop ax
	jmp fat_return
fat_load:		; uses (buffer) es, (count) al, (offset) bx, (cs) cx, and (head) dh to write to ram from disk
	mov ah, 0x03
	push ax
	fat_load_loop:
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
		call output_print_string_ln
		mov ah, 0x00	; reset disk subsystem
		int 13h
		pop ax
		dec ah
		or ah, ah
		jz fat_return
		push ax
		jmp fat_load_loop
fat_load_vbr:		; load volume boot record
	push bx
	push cx
	push dx
	mov cx, [p1_start_cs]	; cyl 0, sec 2
	mov dh, [p1_start_head]	; hed 0
	mov al, 0x01		; sector count
	mov bx, addr_vbr	; offset to vbr in memory
	call fat_load
	pop dx
	pop cx
	pop bx
	jmp fat_return
fat_load_fat:
	push bx
	push cx
	push dx
	mov cx, [p1_start_cs]
	call fat_get_sector
	inc ax;
	call fat_set_sector
	mov dh, [p1_start_head]
	mov al, [addr_vbr_spf]
	mov bx, addr_fat
	call fat_load
	pop dx
	pop cx
	pop bx
	jmp fat_return
fat_return:
	ret
fat_end:
