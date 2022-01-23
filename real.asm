use16
org 0x8000
db "REAL.OS",0
times 1024-($-$$) db 0
