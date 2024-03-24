print:
    pusha                   ; Save registers

    mov ah, 0x0e            ; Set interrupt mode for Teletype Output
    mov bx, 0x0000          ; Set page number and foreground color to 0

print_loop:
    mov al, [bp]            ; Move the character at the base pointer into AL

    test al, al             ; Test if the character is null
    jz print_end            ; If null, end printing

    int 0x10                ; Call BIOS interrupt

    inc bp                  ; Increment the base pointer
    jmp print_loop          ; Jump back to the start of the loop

print_end:
    popa                    ; Restore registers
    ret                     ; Return from the function

line_break:
    pusha                   ; Save registers

    mov ah, 0x0e            ; Set interrupt mode for Teletype Output
    
    mov al, 0x0d            ; Move the carriage return character into AL
    int 0x10                ; Call BIOS interrupt

    mov al, 0x0a            ; Move the line feed character into AL
    int 0x10                ; Call BIOS interrupt

    popa                    ; Restore registers
    ret                     ; Return from the function

move_cursor:
    pusha                   ; Save registers

    mov ah, 0x02            ; Set Cursor Position function
    xor dh, dh              ; Clear DH (row)
    xor dl, dl              ; Clear DL (column)
    
    int 0x10                ; BIOS interrupt
    
    popa                    ; Restore registers
    ret                     ; Return from the function