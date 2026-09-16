[bits 16] ; 16-bit mode
[org 0x7c00] ; global offset

; macros
%macro outb 2
    mov dx, %1 ; set the port address
    mov al, %2 ; set the value to send

    out dx, al ; send the value to the port
%endmacro

%macro inb 1
    mov dx, %1 ; set the port address
    in al, dx ; read the value from the port
%endmacro

; entry point
mov ax, 0x13 ; 'Set Video Mode' function with 320x200 color mode
int 0x10 ; call the BIOS interrupt

xor cx, cx ; clear frame counter
mov byte [DRIVE_NUMBER], dl ; set the drive number

call setup_pit ; set up the programmable interval timer
call setup_sb16 ; set up the sound card

%ifndef SIZE_OPTIMIZED
    mov dx, COM1_SERIAL_PORT ; set the serial port address
    call setup_serial ; set up the serial port
%endif

jmp $ ; loop forever

; includes
%include "src/disk.asm"
%include "src/video.asm"
%include "src/audio.asm"

%ifndef SIZE_OPTIMIZED
    %include "src/serial.asm"

    ; strings used for error/debug messages
    DISK_ERROR_MESSAGE: db "Error: Disk read failed with code 0x", 0x00
    SB16_ERROR_MESSAGE: db "Error: Sound card initialization failed; expected 0xAA, got 0x", 0x00
    SERIAL_TEST_MESSAGE: db "Hello, world!", 0x00
%endif

; pad the rest of the sector with zeros
times 510 - ($ - $$) db 0x00

; boot signature
dw 0xaa55