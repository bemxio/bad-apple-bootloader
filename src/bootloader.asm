[bits 16] ; 16-bit code
[org 0x7c00] ; bootloader offset

FRAME_OFFSET equ 0x1000 ; offset of the frame in memory
FRAME_AMOUNT equ 6567 ; amount of frames on the disk

; set the video mode to 80x25 text mode
mov ah, 0x00 ; 'Set Video Mode' function
mov al, 0x03 ; 80x25 text mode

int 0x10 ; call the BIOS interrupt

; variables for the main loop
mov cx, 0 ; set the frame counter to 0

; set the interrupt handler
cli ; disable interrupts

call setup_pit ; set up the PIT (Programmable Interval Timer)
call setup_ivt ; add the handler entry to the IVT (Interrupt Vector Table)

sti ; re-enable interrupts

loop_forever:
    jmp $ ; jump to the current address (thus, making an infinite loop)

pit_handler:
    cmp cx, FRAME_AMOUNT ; check if the frame counter is equal to the amount of frames on the disk
    je loop_forever ; if so, jump to the infinite loop

    mov bx, FRAME_OFFSET ; set the frame offset in memory

    call read_frame ; read the first frame of the disk into memory
    call print ; print the frame to the screen
    call move_cursor ; move the cursor to the top left corner

    inc cx ; increment the frame counter

    mov al, 0x20 ; set the EOI (End Of Interrupt) signal
    out 0x20, al ; send it to the PIC

    iret ; return from the interrupt

; includes
%include "./src/print.asm"
%include "./src/print_hex.asm"
%include "./src/pit.asm"
%include "./src/disk.asm"

; pad the rest of the sector with null bytes
times 510 - ($ - $$) db 0

; set the magic number
dw 0xaa55