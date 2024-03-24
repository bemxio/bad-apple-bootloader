print_hex:
    pusha                 ; Save all registers to the stack

    mov ch, cl            ; Copy the value to convert
    shr ch, 0x04          ; Shift the value 4 bits to the right
    call print_hex_digit  ; Convert and print the high nibble

    mov ch, cl            ; Copy the value to convert
    and ch, 0x0f          ; Mask out the low nibble
    call print_hex_digit  ; Convert and print the low nibble

    popa                  ; Restore registers
    ret                   ; Return from the function

print_hex_digit:
    add ch, '0'           ; Convert value to ASCII character

    cmp ch, '9'           ; Check if the value is less than or equal to '9'
    jle print_hex_char    ; If so, jump to printing the character

    add ch, 0x07          ; Adjust value to convert to correct ASCII character

print_hex_char:
    mov al, ch            ; Move the value to convert to the right register
    mov ah, 0x0e          ; Set the interrupt mode to "Teletype Output"

    int 0x10              ; Call the BIOS interrupt

    ret                   ; Return from the function