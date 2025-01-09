COM1_SERIAL_PORT equ 0x3f8 ; COM1 serial port address
BAUD_RATE_DIVISOR equ 3 ; baud rate divisor (115200 / 3 = 38400 baud)
CONNECTION_PARAMETERS equ 0x03 ; connection parameters (8 bits, no parity, 1 stop bit)

setup_serial:
    pusha ; save registers

    xor al, al ; disable all interrupts
    inc dx ; set the IER address
    out dx, al ; send the command to the IER

    mov al, 0x80 ; set the DLAB bit
    add dx, 0x02 ; set the LCR address
    out dx, al ; send the command to the LCR

    mov al, BAUD_RATE_DIVISOR ; get the low byte of the divisor
    sub dx, 0x03 ; reset the port address
    out dx, al ; send the byte to the port

    xor al, al ; clear the high byte of the divisor
    inc dx ; set the IER address
    out dx, al ; send the high byte of the divisor

    mov al, CONNECTION_PARAMETERS ; set the connection parameters
    add dx, 0x02 ; set the LCR address
    out dx, al ; send the command to the LCR

    mov al, 0xc7 ; enable and clear the FIFO with 14-byte threshold
    dec dx ; set the FCR address
    out dx, al ; send the command to the FCR

    mov al, 0x0f ; enable the DTR, RTS, OUT1 and OUT2 pins
    add dx, 0x02 ; set the MCR address
    out dx, al ; send the command to the MCR

    popa ; restore registers
    ret ; return from function

print:
    pusha ; save registers

    print_loop:
        mov al, [si] ; load the character from the string

        test al, al ; check if the character is null
        jz print_end ; if so, print is done

        out dx, al ; send the character to the serial port

        inc si ; move to the next character
        jmp print_loop ; repeat the loop

    print_end:
        popa ; restore registers
        ret ; return from function

line_break:
    pusha ; save registers

    mov al, 0x0d ; carriage return
    out dx, al ; send the character to the serial port

    mov al, 0x0a ; line feed
    out dx, al ; send the character to the serial port

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
        out dx, al ; send the character to the serial port

        ret ; return from function