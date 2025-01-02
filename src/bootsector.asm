[bits 16] ; 16-bit mode
[org 0x7c00] ; global offset

cli ; disable interrupts

mov ax, 0x13 ; 'Set Video Mode' function with 320x200 color mode
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

    call read_frame ; read the frame into the video memory
    inc cx ; increment the frame counter

    mov al, 0x20 ; EOI signal
    out 0x20, al ; send it to the PIT

    iret ; return from interrupt

; includes
%include "src/print.asm"
%include "src/pit.asm"
%include "src/disk.asm"

; pad the rest of the sector with zeros
times 510 - ($ - $$) db 0x00

; boot signature
dw 0xaa55