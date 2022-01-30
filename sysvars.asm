addr_svs	= 0x0500		; 0200 bytes ; system variable sector
addr_svs_pdv 	= 0x0000 + addr_svs	; 0001 bytes ; primary disk value
addr_svs_bps	= 0x0001 + addr_svs	; 0002 bytes ; bytes per sector
addr_svs_spt	= 0x0003 + addr_svs	; 0002 bytes ; sectors per track
addr_svs_tph	= 0x0005 + addr_svs	; 0002 bytes ; tracks per head
addr_svs_thc	= 0x0007 + addr_svs	; 0002 bytes ; total head count
addr_svs_dva	= 0x0009 + addr_svs	; 0002 bytes ; disk vbr address
addr_svs_dvs	= 0x000B + addr_svs	; 0002 bytes ; disk vbr sector
addr_svs_dvc	= 0x000D + addr_svs	; 0002 bytes ; disk vbr count
addr_svs_dfa	= 0x000F + addr_svs	; 0002 bytes ; disk fat address
addr_svs_dfs	= 0x0011 + addr_svs	; 0002 bytes ; disk fat sector
addr_svs_dfc	= 0x0013 + addr_svs	; 0002 bytes ; disk fat count
addr_svs_dda	= 0x0015 + addr_svs	; 0002 bytes ; disk dir address
addr_svs_dds	= 0x0017 + addr_svs	; 0002 bytes ; disk dir sector
addr_svs_ddc	= 0x0019 + addr_svs	; 0002 bytes ; disk dir count
addr_svs_dcs	= 0x001B + addr_svs	; 0002 bytes ; disk cluster sector

