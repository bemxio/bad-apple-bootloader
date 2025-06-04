BUFFER_OFFSET: dw 0x7e00 ; offset of the buffer

decode_frame:
    pusha ; save registers

    mov si, word [BUFFER_OFFSET] ; load the offset of the buffer

    mov di, 0xa000 ; set the video memory segment
    mov es, di ; move the value to the extra segment register
    xor di, di ; clear the destination index

    decode_frame_loop:
        lodsb ; load the run length from the buffer

        mov cl, al ; move the run length into the high byte
        lodsb ; load the run byte from the buffer

        test cl, cl ; check if the run length is zero
        jnz decode_frame_write ; if not, repeat the loop

        mov si, 0x7e00 ; reset the source index
        call read_chunk ; read a chunk of data from the disk

        jmp decode_frame_loop ; jump back to the main loop

        decode_frame_write:
            stosb ; store the run byte in the video memory

            cmp di, 0xfa00 ; compare the destination index to the end of the video memory
            je decode_frame_end ; if equal, end the function

            dec cl ; decrement the run length
            jnz decode_frame_write ; if not zero, repeat the write loop

            jmp decode_frame_loop ; jump back to the main loop

    decode_frame_end:
        mov word [BUFFER_OFFSET], si ; save the source index

        popa ; restore registers
        ret ; return from function