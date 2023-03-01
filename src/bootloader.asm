[bits 16] ; 16-bit code
[org 0x7c00] ; bootloader offset

FRAME_OFFSET equ 0x1000 ; offset of the frame in memory
FRAME_AMOUNT equ 6567 ; amount of frames on the disk

; set the video mode to 320x200 grayscale graphics mode
mov ah, 0x00 ; 'Set Video Mode' function
mov al, 0x05 ; 320x200 grayscale graphics mode

int 0x10 ; call the BIOS interrupt

; variables for the main loop
mov cx, 0 ; set the frame counter to 0

loop:
    cmp cx, FRAME_AMOUNT ; check if the frame counter is equal to the amount of frames on the disk
    je end ; if so, jump to the end of the program

    mov bx, FRAME_OFFSET ; set the frame offset in memory

    call read_frame ; read the first frame of the disk into memory
    call display_frame ; display the frame
    
    ; debugging purposes
    ;mov ah, 0x00 ; 'Read Character' function
    ;int 0x16 ; call the BIOS interrupt

    inc cx ; increment the frame counter
    jmp loop ; infinite loop

end:
    jmp $ ; infinite loop

; includes
%include "./src/display.asm"
%include "./src/print.asm"
%include "./src/print_hex.asm"
%include "./src/disk.asm"

times 510 - ($ - $$) db 0 ; pad to 510 bytes
dw 0xaa55 ; magic signature