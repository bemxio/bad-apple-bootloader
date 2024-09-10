print:
    pusha ; save registers

    mov ah, 0x0e ; 'Teletype Output' function
    xor bh, bh ; set page number to 0

    print_loop:
        mov al, [si] ; move the character from the source index to the register

        test al, al ; check if the character is null
        jz print_end ; if so, print is done

        int 0x10 ; call the BIOS interrupt

        inc si ; move to the next character
        jmp print_loop ; repeat

    print_end:
        popa ; restore registers
        ret ; return from function

line_break:
    pusha ; save registers

    mov ah, 0x0e ; 'Teletype Output' function
    
    mov al, 0x0d ; carriage return character
    int 0x10 ; call the BIOS interrupt

    mov al, 0x0a ; line feed character
    int 0x10 ; call the BIOS interrupt

    popa ; restore registers
    ret ; return from function

move_cursor:
    pusha ; save registers

    mov ah, 0x02 ; 'Set Cursor Position' function
    xor dh, dh ; clear the row counter
    xor dl, dl ; clear the column counter
    
    int 0x10 ; call the BIOS interrupt
    
    popa ; restore registers
    ret ; return from function