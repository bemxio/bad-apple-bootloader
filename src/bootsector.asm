[bits 16] ; 16-bit mode
[org 0x7c00] ; global offset

mov ax, 0x13 ; 'Set Video Mode' function with 320x200 256-color video mode
int 0x10 ; call the BIOS interrupt

xor cx, cx ; clear frame counter
mov byte [DRIVE_NUMBER], dl ; set the drive number

call setup_pit ; set up the programmable interval timer

%ifndef SIZE_OPTIMIZED
    mov dx, COM1_SERIAL_PORT ; set the serial port address
    call setup_serial ; set up the serial port
%endif

jmp $ ; loop forever

pit_handler:
    cmp cx, FRAME_AMOUNT ; compare frame counter to frame amount
    je $ ; if equal, loop forever

    call decode_frame ; read the frame into the video memory
    inc cx ; increment the frame counter

    %ifndef SIZE_OPTIMIZED
        mov bx, cx ; save the frame counter

        mov cl, bh ; set the high byte of the frame counter
        call print_hex ; print the high byte of the frame counter

        mov cl, bl ; set the low byte of the frame counter
        call print_hex ; print the low byte of the frame counter

        mov al, 0x0d ; carriage return
        out dx, al ; send the character to the serial port

        mov cx, bx ; restore the frame counter
    %endif

    mov al, 0x20 ; EOI signal
    out 0x20, al ; send it to the PIT

    iret ; return from interrupt

; includes
%include "src/disk.asm"
%include "src/video.asm"

%ifndef SIZE_OPTIMIZED
    %include "src/serial.asm"

    ; strings
    SERIAL_TEST_MESSAGE: db "Bad Apple Bootloader", 0x00
    DISK_ERROR_MESSAGE: db "Error: Disk read failed with code 0x", 0x00
%endif

; pad the rest of the sector with zeros
times 510 - ($ - $$) db 0x00

; boot signature
dw 0xaa55