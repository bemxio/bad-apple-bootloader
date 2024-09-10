[bits 16] ; 16-bit mode
[org 0x7c00] ; global offset

FRAME_ADDRESS equ 0x7e00 ; the address in memory to read the frame to
;FRAME_AMOUNT equ 6567 ; the amount of frames to read

cli ; disable interrupts

mov ax, 0x03 ; 80x25 text mode
int 0x10 ; call the BIOS interrupt

xor cx, cx ; clear frame counter

call setup_pit ; set up the Programmable Interval Timer
call setup_ivt ; set up the Interrupt Vector Table

sti ; re-enable interrupts

loop_forever:
    jmp loop_forever ; loop forever

pit_handler:
    cmp cx, FRAME_AMOUNT ; compare frame counter to frame amount
    je loop_forever ; if equal, loop forever

    mov si, FRAME_ADDRESS ; load the address of the frame

    call read_frame ; read the frame from the disk
    call print ; print the frame
    call move_cursor ; move the cursor to the top of the screen

    inc cx ; increment the frame counter

    mov al, 0x20 ; EOI signal
    out 0x20, al ; send it to the PIT

    iret ; return from interrupt

; includes
%include "src/print.asm"
%include "src/print_hex.asm"
%include "src/pit.asm"
%include "src/disk.asm"

; pad the rest of the sector with zeros
times 510 - ($ - $$) db 0x00

; boot signature
dw 0xaa55