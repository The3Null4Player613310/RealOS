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
addr_dte_neo = 0x20		; 0032 bytes ; next entry offset
