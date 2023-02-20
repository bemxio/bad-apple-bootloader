print_hex: ; we'll assume that it's called with dx = 0x1234
    pusha
    mov cx, 0 ; the index variable

step1: ; convert last char of 'dx' to ascii
    cmp cx, 4 ; loop 4 times
    je print_hex_end

    mov ax, dx
    and ax, 0x000f ; 0x1234 -> 0x0004 by masking first three to zeros
    add al, 0x30 ; add 0x30 to N to convert it to ASCII "N"

    cmp al, 0x39 ; if > 9, add extra 8 to represent 'A' to 'F'
    jle step2 
    
    add al, 7 ; 'A' is ASCII 65 instead of 58, so 65 - 58 = 7

step2: ; get the correct position of the string to place the ASCII char
    mov bx, HEX_OUT + 5 ; base + length
    sub bx, cx ; the index variable yet again

    mov [bx], al ; copy the ASCII char on 'al' to the position pointed by 'bx'
    ror dx, 4 ; 0x1234 -> 0x4123 -> 0x3412 -> 0x2341 -> 0x1234
    
    ; increment index and loop
    add cx, 1
    jmp step1

print_hex_end: ; prepare the parameter and call the function
    mov bx, HEX_OUT ; remember that print receives parameters in 'bx'
    call print

    popa
    ret

HEX_OUT:
    db "0x0000", 0