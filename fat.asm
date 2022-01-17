; volume boot record offsets	; 0512 bytes ; volume boot record
addr_vbr_oem = 0x03		; 0008 bytes ; oem name
addr_vbr_bps = 0x0B		; 0002 bytes ; bytes per sector
addr_vbr_spc = 0x0D		; 0001 bytes ; sectors per cluster
addr_vbr_rsc = 0x0E		; 0002 bytes ; reserved sector count
addr_vbr_tfc = 0x10		; 0001 bytes ; total fat count
addr_vbr_mre = 0x11		; 0002 bytes ; max root entries
addr_vbr_tsc = 0x13		; 0002 bytes ; total sector count
addr_vbr_mdv = 0x15		; 0001 bytes ; media descriptor value
addr_vbr_spf = 0x16		; 0002 bytes ; sectors per fat
addr_vbr_spt = 0x18		; 0002 bytes ; sectors per track
addr_vbr_thc = 0x1A		; 0002 bytes ; total head count
addr_vbr_hsl = 0x1C		; 0004 bytes ; hidden sector count low
addr_vbr_hsh = 0x1E		; 0002 bytes ; hidden sector count high
addr_vbr_tsl = 0x20		; 0004 bytes ; total sector count low
addr_vbr_tsh = 0x22		; 0002 bytes ; total sector count high

; allocation table entry offsets; 0003 bytes ; allocation table	entry
addr_ate_neo = 0x03		; 0003 bytes ; next entry offset

; directory table entry offsets	; 0032 bytes ; directory table entry
addr_dte_sfn = 0x00		; 0008 bytes ; short file name
addr_dte_sfe = 0x08		; 0003 bytes ; short file extension
addr_dte_fav = 0x0B		; 0001 bytes ; file attribute value
addr_dte_cav = 0x0C		; 0001 bytes ; case attribute value
addr_dte_ctf = 0x0D		; 0001 bytes ; creation time fine
addr_dte_ctv = 0x0E		; 0002 bytes ; creation time value
addr_dte_cdv = 0x10		; 0002 bytes ; creation date value
addr_dte_adv = 0x12		; 0002 bytes ; access date value
addr_dte_eai = 0x14		; 0002 bytes ; EA index			;wip
addr_dte_mtv = 0x16		; 0002 bytes ; modification time value
addr_dte_mdv = 0x18		; 0002 bytes ; modification date value
addr_dte_fcv = 0x1A		; 0002 bytes ; first cluster value 
addr_dte_tbl = 0x1C		; 0004 bytes ; total byte count low
addr_dte_tbh = 0x1E		; 0002 bytes ; total byte count high
fat_init:
jmp fat_end
addr_vbr dw 0x7A00
addr_fat dw 0x0000
addr_dir dw 0x0000
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
fat_load_vbr:	; load volume boot record
	mov cx, [p1_start_cs]		; cyl 0, sec 2
	mov dh, [p1_start_head]		; hed 0
	mov al, 0x01			; sector count
	mov bx, [addr_vbr]		; offset to vbr in memory
	call fat_load
	jmp fat_return
fat_load_fat:	; load file allocation table
	
	mov bx,	[addr_vbr]		; update addr_fat
	mov [addr_fat], bx
	mov ax, [bx + addr_vbr_spf]
	mov dx, [bx + addr_vbr_bps]
	mul dx
	sub [addr_fat], ax

	mov cx, [p1_start_cs]		; increment sector in cs
	call fat_get_sector
	inc ax;
	call fat_set_sector

	mov dh, [p1_start_head]		; set head

	;mov bx, [addr_vbr]		; set sector count
	mov al, [bx + addr_vbr_spf]

	mov bx, [addr_fat]		; set buffer address
	call fat_load

	jmp fat_return
fat_load_root:	; load root directory

	mov ax, [addr_fat]		; update addr_dir
	mov [addr_dir], ax
	mov bx, [addr_vbr]
	mov ax, [bx + addr_vbr_mre]
	mov dx, 0x0020
	mul dx
	sub [addr_dir], ax
	
	mov ax, [bx + addr_vbr_tfc]	; increment sector in cs by (tfc*spf)+1
	mov dl, [bx + addr_vbr_spf]
	mul dx
	inc ax
	mov dx, ax
	mov cx, [p1_start_cs]
	call fat_get_sector
	add ax, dx	
	call fat_set_sector

	mov dh, [p1_start_head]		; set head

	push cx				; set sector count
	mov ax,	[addr_fat]
	sub ax, [addr_dir]
	mov cx, [bx + addr_vbr_bps]
	div cx
	pop cx
		
	mov bx, [addr_dir]		; set buffer address
	call fat_load

	jmp fat_return
fat_return:
	ret
fat_end:
