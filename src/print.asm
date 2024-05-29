print:
    pusha ; save registers

    mov ah, 0x0e ; set "Teletype Output" mode
    xor bh, bh ; set page number to 0

    print_loop:
        mov al, [si] ; move the character from the source index to the register

        test al, al ; check if the character is null
        jz print_end ; if so, we're done

        int 0x10 ; call the BIOS interrupt

        inc si ; move to the next character
        jmp print_loop ; repeat

    print_end:
        popa ; restore registers
        ret ; return from function
