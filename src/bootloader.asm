[bits 16] ; set the code to 16-bit mode
[org 0x7c00] ; set the global offset (0x7c00 is where the BIOS loads the bootloader)

; set video mode
mov ah, 0x00 ; "Set Video Mode" mode
mov al, 0x05 ; 320x200 2-bit grayscale

int 0x10 ; BIOS interrupt

; initialize IVT and PIT
cli ; disable interrupts

call pit_init ; set up the programmable interrupt timer
call ivt_init ; set up the interrupt vector table

sti ; enable interrupts 

; loop forever
loop_forever:
    jmp loop_forever ; loop forever

; PIT handler
pit_handler:
    cmp cx, FRAME_AMOUNT ; check frame count against the amount of frames
    je loop_forever ; if they are equal, loop forever

    mov esi, FRAME_ADDRESS ; set the address of the frame buffer

    call read_frame ; read the frame from the disk
    call draw_frame ; draw the frame

    inc cx ; increment the frame count

    mov al, 0x20 ; set PIC EOI
    out 0x20, al ; send EOI to the PIC

    iret ; return from interrupt

; constants
FRAME_ADDRESS equ 0x8000 ; the address of the frame buffer

; includes
%include "./src/graphics.asm"
%include "./src/pit.asm"
%include "./src/disk.asm"

; pad the rest of the sector with null bytes
times 510 - ($ - $$) db 0

; set the magic number
dw 0xaa55