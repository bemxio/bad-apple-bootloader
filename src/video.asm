IVT_IRQ0_OFFSET equ 0x0020 ; offset of the first IRQ in the IVT
VIDEO_CHUNK_SIZE equ 64 ; 64 sectors (32,768 bytes) per chunk

VIDEO_ADDRESS_PACKET:
    db 0x10 ; size of the packet (16 bytes)
    db 0x00 ; unused byte, always 0

    dw VIDEO_CHUNK_SIZE ; number of sectors to read
    dw 0x7e00 ; buffer offset
    dw 0x00 ; buffer segment

    VIDEO_SECTOR_OFFSET: dd 0x01 ; sector offset (lower 32-bits)
    dd 0x00 ; sector offset (upper 32-bits)

VIDEO_BUFFER_OFFSET: dw 0x7e00 ; memory offset for the compressed data chunk

setup_pit:
    pusha ; save registers

    ; configure PIT for generating interrupts
    cli ; disable interrupts

    mov al, 0x34 ; command byte (channel 0, lobyte/hibyte, rate generator)
    out 0x43, al ; send the command byte to the PIT

    mov ax, PIT_RELOAD_VALUE ; set the reload value
    out 0x40, al ; send the reload value low byte to the PIT

    mov al, ah ; move the high byte to the low byte
    out 0x40, al ; send the reload value high byte to the PIT

    ; add the interrupt handler to the IVT
    mov word [IVT_IRQ0_OFFSET], pit_handler ; set the handler offset in the IVT
    mov word [IVT_IRQ0_OFFSET + 2], cs ; set the handler segment in the IVT

    sti ; re-enable interrupts

    popa ; restore registers
    ret ; return from function

decode_frame:
    pusha ; save registers

    mov si, word [VIDEO_BUFFER_OFFSET] ; load the offset of the buffer

    mov di, 0xa000 ; set the video memory segment
    mov es, di ; move the value to the extra segment register
    xor di, di ; clear the destination index

    decode_frame_loop:
        lodsb ; load the run length from the buffer

        mov cl, al ; move the run length into the high byte
        lodsb ; load the run byte from the buffer

        test cl, cl ; check if the run length is zero
        jnz decode_frame_write ; if not, repeat the loop

        mov si, VIDEO_ADDRESS_PACKET ; load the address of the packet
        call read_chunk ; read a chunk of data from the disk
        add dword [VIDEO_SECTOR_OFFSET], CHUNK_SIZE ; increment the sector offset by the chunk size

        mov si, 0x7e00 ; reset the source index
        jmp decode_frame_loop ; jump back to the main loop

        decode_frame_write:
            stosb ; store the run byte in the video memory

            cmp di, 0xfa00 ; compare the destination index to the end of the video memory
            je decode_frame_end ; if equal, end the function

            dec cl ; decrement the run length
            jnz decode_frame_write ; if not zero, repeat the write loop

            jmp decode_frame_loop ; jump back to the main loop

    decode_frame_end:
        mov word [VIDEO_BUFFER_OFFSET], si ; save the source index

        popa ; restore registers
        ret ; return from function

pit_handler:
    cmp cx, FRAME_AMOUNT ; compare frame counter to frame amount
    je $ ; if equal, loop forever

    call decode_frame ; read the frame into the video memory
    inc cx ; increment the frame counter

    %ifndef SIZE_OPTIMIZED
        mov bx, cx ; save the frame counter

        mov cl, bh ; set the high byte of the frame counter
        call print_hex ; print the high byte of the frame counter

        mov cl, bl ; set the low byte of the frame counter
        call print_hex ; print the low byte of the frame counter

        mov al, 0x0d ; carriage return
        out dx, al ; send the character to the serial port

        mov cx, bx ; restore the frame counter
    %endif

    mov al, 0x20 ; EOI signal
    out 0x20, al ; send the signal to the PIC

    iret ; return from interrupt