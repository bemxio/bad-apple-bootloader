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