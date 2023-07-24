print_hex:  
    pusha ; save all of the registers to the stack

    ; convert the high nibble to ASCII character
    mov ch, cl ; copy the value to convert
    shr ch, 4 ; shift the value 4 bits to the right

    call print_hex_conversion ; convert and print the high nibble

    ; convert the low nibble to ASCII character
    mov ch, cl ; copy the value to convert
    and ch, 0x0f ; mask out the low nibble

    call print_hex_conversion ; convert and print the low nibble

    popa ; restore registers
    ret ; return from the function

    print_hex_conversion:
        add ch, '0' ; convert value to ASCII character

        cmp ch, '9' ; check if the value is less or equal to '9'
        jle print_hex_digit ; if it is, jump to print_hex_digit

        add ch, 7 ; adjust the value to convert to the correct ASCII character

    print_hex_digit:
        mov al, ch ; move the value to convert to the right register

        mov ah, 0x0e ; change the interrupt mode to "Teletype Output"
        int 0x10 ; call the BIOS interrupt

        ret ; return from the function