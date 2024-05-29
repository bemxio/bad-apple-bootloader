draw_frame:
    pusha ; save registers

    mov dx, 0x00 ; set the row position to 0
    mov cx, 0x00 ; set the column position to 0

    draw_frame_loop:
        mov al, [esi] ; get the next byte from the frame

        mov ah, 0x0c ; 'Write Graphics Pixel' function
        int 0x10 ; call the BIOS interrupt

        inc cx ; increment the column position
        inc esi ; increment the frame address

        cmp cx, 320 ; compare the column position to 320
        jne draw_frame_loop ; if it's not equal to the value, then loop back

    draw_frame_line:
        mov cx, 0x00 ; set the column position to 0
        inc dx ; increment the row position

        cmp dx, 200 ; compare the row position to 200
        jl draw_frame_loop ; if it's less than the value, then jump back to the loop

    draw_frame_end:
        popa ; restore registers
        ret ; return from function