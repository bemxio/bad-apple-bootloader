[bits 16] ; 16-bit code
[org 0x7c00] ; bootloader offset

jmp $ ; infinite loop

; includes
%include "./src/print.asm"

times 510 - ($ - $$) db 0 ; pad to 510 bytes
dw 0xaa55 ; magic signature