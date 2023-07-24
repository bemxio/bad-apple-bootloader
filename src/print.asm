print:
    pusha ; save registers

    print_start:
        mov al, [bx] ; move the character at the base address into `al`

        cmp al, 0 ; check if the character is a null byte
        je print_end ; if so, jump to `print_end`

        mov ah, 0x0e ; change the interrupt mode to "Teletype Output"
        int 0x10 ; call the BIOS interrupt

        inc bx ; increment the base address
        jmp print_start ; jump back to the start of the loop
    
    print_end:
        popa ; restore registers
        ret ; return from the function

line_break:
    pusha ; save registers
    mov ah, 0x0e ; change the interrupt mode to "Teletype Output"
    
    mov al, 0x0a ; move the line feed character into `al`
    int 0x10 ; call the BIOS interrupt
    
    mov al, 0x0d ; move the carriage return character into `al`
    int 0x10 ; call the BIOS interrupt
    
    popa ; restore registers
    ret ; return from the function

move_cursor:
    pusha ; save registers

    mov ah, 0x02 ; 'Set Cursor Position' function
    mov bh, 0x00 ; page number, 0 by default

    mov dl, 0x00 ; row value (top)
    mov dh, 0x00 ; column value (left)
    
    int 0x10 ; BIOS interrupt
    
    popa ; restore registers
    ret ; return from the function

print_frame:
    pusha ; save registers

    call print ; print the string
    call move_cursor ; move the cursor to the top left corner

    mov ah, 0x86 ; change the interrupt mode to "Wait"

    mov cx, 0x00 ; unused here (upper 16-bits)
    mov dx, DELAY_TIME ; wait for `DELAY_TIME` microseconds (lower 16-bits)

    int 0x15 ; call the BIOS interrupt

    popa ; restore registers
    ret ; return from the function

DELAY_TIME equ 0x2b67 ; the amount of time to wait between each frame (in microseconds)