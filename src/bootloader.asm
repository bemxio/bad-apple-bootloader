[bits 16]
[org 0x7c00]

FRAME_ADDRESS equ 0x7e00
;FRAME_AMOUNT equ 6567

cli                     ; Disable interrupts

mov ax, 0x03            ; Set Video Mode 80x25 text mode
int 0x10

xor cx, cx              ; Reset frame counter

call setup_pit          ; Set up Programmable Interval Timer
call setup_ivt          ; Set up Interrupt Vector Table

sti                     ; Re-enable interrupts

loop_forever:
    jmp loop_forever       ; Infinite loop

pit_handler:
    cmp cx, FRAME_AMOUNT    ; Check frame counter against frame amount
    je loop_forever        ; Jump if equal

    mov bp, FRAME_ADDRESS  ; Set frame offset in memory

    call read_frame        ; Read frame into memory
    call print             ; Print frame to the screen
    call move_cursor       ; Move cursor to top left corner

    inc cx                 ; Increment frame counter

    mov al, 0x20           ; Send EOI signal
    out 0x20, al

    iret                   ; Return from interrupt

%include "./src/print.asm"
%include "./src/print_hex.asm"
%include "./src/pit.asm"
%include "./src/disk.asm"

times 510 - ($ - $$) db 0

dw 0xaa55