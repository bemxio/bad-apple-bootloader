DRIVE_NUMBER: db 0x80 ; main hard drive
CHUNK_SIZE equ 64 ; 64 sectors (32,768 bytes) per chunk

DISK_ADDRESS_PACKET:
    db 0x10 ; size of the packet (16 bytes)
    db 0x00 ; unused byte, always 0

    dw CHUNK_SIZE ; number of sectors to read
    dw 0x7e00 ; buffer offset
    dw 0x00 ; buffer segment

    SECTOR_OFFSET: dd 0x01 ; sector offset (lower 32-bits)
    dd 0x00 ; sector offset (upper 32-bits)

BUFFER_OFFSET: dw 0x7e00 ; offset of the chunk buffer

read_chunk:
    pusha ; save registers

    mov ah, 0x42 ; 'Extended Read Sectors From Drive' function
    mov dl, byte [DRIVE_NUMBER] ; load the drive number
    mov si, DISK_ADDRESS_PACKET ; load the address of the packet

    int 0x13 ; BIOS interrupt
    jc disk_error ; if carry flag is set, an error occurred

    add dword [SECTOR_OFFSET], CHUNK_SIZE ; increment the sector offset by the chunk size

    popa ; restore registers
    ret ; return from function

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

disk_error:
    %ifndef SIZE_OPTIMIZED
        mov si, DISK_ERROR_MESSAGE ; load the address of the error message
        mov cl, ah ; load the error code

        call print ; print the error message
        call print_hex ; print the error code in hex
        call line_break ; add a line break
    %endif

    hlt ; halt the system