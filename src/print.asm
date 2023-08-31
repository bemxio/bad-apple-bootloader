print:
    pusha ; save registers

    mov ah, 0x0e ; change the interrupt mode to "Teletype Output"
    mov bx, 0x00 ; set the page number and foreground color to 0

    print_loop:
        mov al, [bp] ; move the character at the base pointer into `al`

        cmp al, 0x00 ; check if the character is a null byte
        je print_end ; if so, jump to `print_end`

        int 0x10 ; call the BIOS interrupt

        inc bp ; increment the base pointer
        jmp print_loop ; jump back to the start of the loop
    
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