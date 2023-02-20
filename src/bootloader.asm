[bits 16] ; 16-bit code
[org 0x7c00] ; bootloader offset

FRAME_OFFSET equ 0x1000 ; offset of the frame in memory
FRAME_AMOUNT equ 6567 ; amount of frames on the disk

mov cx, 0 ; set the frame counter to 0

mov cl, 0x02 ; set the sector to 0x02 (the first available sector on the disk)
mov dh, 0 ; set the head to 0

loop:
    cmp cx, FRAME_AMOUNT ; check if the frame counter is equal to the amount of frames on the disk
    je end ; if so, jump to the end of the program

    mov bx, FRAME_OFFSET ; set the frame offset in memory

    call read_frame ; read the first frame of the disk into memory
    call print ; print the frame
    
    inc cx ; increment the frame counter
    jmp loop ; infinite loop

end:
    jmp $ ; infinite loop

; includes
%include "./src/print.asm"
%include "./src/print_hex.asm"
%include "./src/disk.asm"

times 510 - ($ - $$) db 0 ; pad to 510 bytes
dw 0xaa55 ; magic signature