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

println:
    call print
    call line_break

    ret