[bits 16] ; 16-bit mode
[org 0x7c00] ; global offset

mov ax, 0x13 ; 'Set Video Mode' function with 320x200 color mode
int 0x10 ; call the BIOS interrupt

xor cx, cx ; clear frame counter
mov byte [DRIVE_NUMBER], dl ; set the drive number
mov dx, COM1_SERIAL_PORT ; set the serial port address

cli ; disable interrupts

call setup_serial ; set up the serial port
;call setup_pit ; set up the Programmable Interval Timer
;call setup_ivt ; set up the Interrupt Vector Table

sti ; re-enable interrupts

%rep 1
    call decode_frame ; read the frame into the video memory
%endrep

loop_forever:
    jmp $ ; loop forever

pit_handler:
    cmp cx, FRAME_AMOUNT ; compare frame counter to frame amount
    je loop_forever ; if equal, loop forever

    call decode_frame ; read the frame into the video memory
    inc cx ; increment the frame counter

    mov al, 0x20 ; EOI signal
    out 0x20, al ; send it to the PIT

    iret ; return from interrupt

; includes
%include "src/disk.asm"
%include "src/rle.asm"
%include "src/pit.asm"
%include "src/serial.asm"

; debug messages
%ifdef VERBOSE_OUTPUT
    DEBUG_TYPE_SERIAL: db "Serial port", 0x00
    DEBUG_TYPE_PIT: db "PIT", 0x00
    DEBUG_TYPE_IVT: db "IVT", 0x00
    DEBUG_SUCCESSFUL_INIT: db " successfully initialized", 0x00
%endif

; pad the rest of the sector with zeros
times 510 - ($ - $$) db 0x00

; boot signature
dw 0xaa55