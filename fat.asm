fat_init:
	;call fat_compare_test
	call fat_load_vbr
	call fat_load_fat
	call fat_load_root
jmp fat_end
addr_query db "FILENAME",0
addr_entry db "FILENAME"
fat_fix_vbr:		; fix vbr
	push es
	mov dl, [addr_svs_pdv]
	mov ah, 0x08
	int 13h
	mov bx, [addr_svs_dva]
	shr dx, 0x08
	inc dx
	mov [bx + addr_vbr_thc], dx
	call disk_get_sector
	mov [bx + addr_vbr_spt], ax
	pop es
	jmp fat_return
fat_load_vbr:		; load volume boot record
	;mov al, 'V'
	;call put_char

	mov cx, [p1_start_cs]		; cyl 0, sec 2
	mov dh, [p1_start_head]		; hed 0
	call disk_get_sec
	mov [addr_svs_dvs], ax

	mov ax, 0x0001
	mov [addr_svs_dvc], ax

	mov ax, 0x7A00
	mov [addr_svs_dva], ax

	mov ax, [addr_svs_dvs]		; sector number
	mov bx, [addr_svs_dva]		; offset to vbr in memory
	mov cx, [addr_svs_dvc]		; sector count
	call disk_load
	call fat_fix_vbr
	jmp fat_return
fat_load_fat:		; load file allocation table
	;mov al, 'F'
	;call put_char

	mov ax, [addr_svs_dvs]		; update sector
	add ax, [addr_svs_dvc]
	mov [addr_svs_dfs], ax

	mov bx, [addr_svs_dva]		; update count
	mov ax, [bx + addr_vbr_spf]
	mov [addr_svs_dfc], ax

	mov bx,	[addr_svs_dva]		; update address
	mov [addr_svs_dfa], bx
	mov ax, [bx + addr_vbr_spf]
	mov dx, [bx + addr_vbr_bps]
	mul dx
	sub [addr_svs_dfa], ax
	
	mov ax, [addr_svs_dfs]		; load sectors
	mov bx, [addr_svs_dfa]
	mov cx, [addr_svs_dfc]
	call disk_load
	jmp fat_return
fat_load_root:		; load root directory
	;mov al, 'R'
	;call put_char

	mov bx, [addr_svs_dva]		; update sector
	mov ax, [addr_svs_dfc]
	mov dx, [bx + addr_vbr_tfc]
	mul dx
	add ax, [addr_svs_dfs]
	mov [addr_svs_dds], ax

	mov bx, [addr_svs_dva]		; update count
	mov ax, [bx + addr_vbr_mre]
	mov dx, addr_dte_neo
	mul dx
	mov cx, [addr_svs_bps]
	xor dx, dx
	div cx
	or dx, dx
	jz fat_load_root_skip
	inc ax
	fat_load_root_skip: 
	mov [addr_svs_ddc], ax

	mov bx, [addr_svs_dva]		; update address
	mov ax, [addr_svs_dfa]
	mov [addr_svs_dda], ax
	mov ax, [addr_svs_ddc]
	mov dx, [bx + addr_vbr_bps]
	mul dx
	sub [addr_svs_dda], ax

	mov ax, [addr_svs_dds]		; load sectors
	mov bx, [addr_svs_dda]
	mov cx, [addr_svs_ddc]
	call disk_load
	jmp fat_return
fat_load_file:		; load (file) si to (offset) bx
;	push bx
;	mov bx, [addr_vbr]
;	mov cx, [bx + addr_vbr_mre]
;	mov bx, [addr_dir]
;	fat_load_file_loop:
;		or cx, cx
;		jz fat_load_file_error	; file not found
;		mov ax, [bx + addr_dte_sfe]
;		cmp ax, 0x534f		; SO ; upper 3 bits are not used ; wrong
;		je fat_load_file_load
;		dec cx;
;		add bx, addr_dte_neo
;		jmp fat_load_file_loop
;	fat_load_file_load:
;		mov ax, [bx + addr_dte_fcv]
;		sub ax, 0x02
;		pop bx
;		
;		jmp fat_return
;	fat_load_file_error:
;		mov al, 'E'
;		call put_char
;		pop bx
		jmp fat_return
fat_compare_test:
	mov si, addr_query
	mov di, addr_entry
	call fat_compare
	jnz fat_compare_test_fail
	call debug_print_hex_word
	mov al, 'S'
	call put_char
	jmp fat_return
	fat_compare_test_fail:
	call debug_print_hex_word
	mov al, 'D'
	call put_char
	jmp fat_return
fat_compare:		; compare (file name) si (file entry) di returns (word distance) ax
	push si
	push di
	push bx
	push cx
	push dx
	xor dx, dx
	mov cl, 0x08
	fat_compare_loop:
		or cl, cl
		jz fat_compare_terminate

		mov ah, [ds:si]
		mov al, [ds:di]		

		cmp ax, 0x0020
		je fat_compare_terminate		

		cmp ah, al
		je fat_compare_next
		jg fat_compare_gtr
		jl fat_compare_les
	fat_compare_gtr:
		xor bh, bh
		mov bl, ah
		add dx, bx
		mov bl, al
		sub dx, bx
		jmp fat_compare_next
	fat_compare_les:
		xor bh, bh
		mov bl, al
		add dx, bx
		mov bl, ah
		sub dx, bx
		jmp fat_compare_next
	fat_compare_next:
		dec cl
		inc si
		inc di
		jmp fat_compare_loop
	fat_compare_terminate:
		mov ah, 0x00
		mov al, [ds:si]
		cmp ah, al
		je fat_compare_success
		jmp fat_compare_error
		fat_compare_error:
			mov ax, 0xFFFF
			stc
			jmp fat_compare_pop
		fat_compare_success:
			mov ax, dx
			clc
			or ax, ax
			jmp fat_compare_pop
		fat_compare_pop:
			pop dx
			pop cx
			pop bx
			pop di
			pop si
			jmp fat_return
fat_return:
	ret
fat_end:
