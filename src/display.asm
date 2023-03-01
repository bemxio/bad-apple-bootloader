display_frame:
    pusha ; save registers

    mov cx, 0x00 ; set the column to 0
    mov dx, 0x00 ; set the row to 0

    display_frame_loop:
        mov al, [bx] ; move the pixel byte at the base address into `al`

        cmp al, 0 ; check if the pixel is a null byte
        je display_frame_end ; if so, jump to `print_end`

        mov ah, 0x0c ; 'Write Graphics Pixel' function
        int 0x10 ; call the BIOS interrupt

        inc cx ; increment the column
        cmp cx, 320 ; compare the column to 320

        jle display_frame_newline ; if the column is less than or equal to 320, go to the newline function
        jmp display_frame_loop ; otherwise, loop back to the beginning
    
    display_frame_newline:
        mov cx, 0x00 ; set the column to 0
        inc dx ; increment the row

        cmp dx, 200 ; compare the row to 200

        jg display_frame_end ; if the row is greater than 200, end the function
        jmp display_frame_loop ; otherwise, loop back to the beginning
    
    display_frame_end:
        popa ; restore registers
        ret ; return from the function