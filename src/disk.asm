DRIVE_NUMBER: db 0x80 ; main hard drive

DISK_ADDRESS_PACKET:
    db 0x10 ; size of the packet (16 bytes)
    db 0x00 ; unused byte, always 0

    SECTOR_AMOUNT: dw 0x40 ; number of sectors to read
    BUFFER_OFFSET: dw 0x7e00 ; buffer offset
    BUFFER_SEGMENT: dw 0x00 ; buffer segment

    SECTOR_OFFSET: dd 0x01 ; sector offset (lower 32-bits)
    dd 0x00 ; sector offset (upper 32-bits)

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

disk_error:
    %ifndef SIZE_OPTIMIZED
        mov si, DISK_ERROR_MESSAGE ; load the address of the error message
        mov cl, ah ; load the error code

        call print ; print the error message
        call print_hex ; print the error code in hex
        call line_break ; add a line break
    %endif

    hlt ; halt the system