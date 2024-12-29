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

print_hex:
    pusha ; save registers

    mov ch, cl ; copy the value to another register
    shr ch, 0x04 ; shift right by 4 bits
    call print_hex_digit ; print the high nibble

    mov ch, cl ; copy the value to another register
    and ch, 0x0f ; mask the low nibble
    call print_hex_digit ; print the low nibble

    popa ; restore registers
    ret ; return from function

    print_hex_digit:
        add ch, '0' ; convert the value to ASCII

        cmp ch, '9' ; check if the value is less than or equal to 9
        jle print_hex_char ; if so, print the character

        add ch, 0x07 ; adjust the value to a correct ASCII character

    print_hex_char:
        mov al, ch ; move the character to the register
        mov ah, 0x0e ; 'Teletype Output' function

        int 0x10 ; call the BIOS interrupt

        ret ; return from function