oad_init:
jmp load_end
load_vbr:
	mov bx, 0x7A00
	mov [addr_svs_dva], bx

	mov cx, [p1_start_cs]
	mov dh, [p1_start_head]
	call disk_load_sec
	jmp load_return
load_root:	
	mov bx, [addr_svs_dva]
	mov [addr_svs_dda], bx

	mov cx, [p1_start_cs]		; init sector
	mov dh, [p1_start_head]
	call disk_get_sec
	mov [addr_svs_dds], ax

	mov bx, [addr_svs_dva]		; calculate offset from partition start
	mov ax, [bx + addr_vbr_spf]
	mov cx, [bx + addr_vbr_tfc]
	mul cx
	inc ax
	add [addr_svs_dds], ax

	mov bx, [addr_svs_dva]		; calculate number of sectors to read
	mov ax, [bx + addr_vbr_mre]
	mov cx, addr_dte_neo
	mul cx

	mov cx, [addr_svs_bps]
	xor dx, dx
	div cx				; problem child
	mov [addr_svs_ddc], ax

	mov ax, [addr_svs_ddc]		; calculate address
	mov cx, [addr_svs_bps]
	mul cx
	neg ax
	add ax, [addr_svs_dda]
	mov [addr_svs_dda], ax
	
	mov ax, [addr_svs_dds]
	mov cx, [addr_svs_ddc]
	mov bx, [addr_svs_dda]

	call disk_load
load_return:
	ret
load_end:
