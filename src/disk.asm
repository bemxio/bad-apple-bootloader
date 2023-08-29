FRAME_SIZE equ 4 ; 4 sectors per frame

DISK_ADDRESS_PACKET:
    db 0x10 ; size of the packet, 16 bytes by default
    db 0x00 ; unused, should always be 0

    dw FRAME_SIZE ; number of sectors to read
    dw FRAME_OFFSET ; pointer to the buffer
    dw 0x00 ; page number, 0 by default

    SECTOR_OFFSET dd 0x01 ; offset of the sector to read (lower 32-bits)
    dd 0x00 ; unused here (upper 32-bits)

read_frame:
    mov ah, 0x42 ; 'Extended Read Sectors From Drive' function
    mov si, DISK_ADDRESS_PACKET ; load the address of the packet

    int 0x13 ; BIOS interrupt
    jc disk_error ; if carry flag is set, an error occurred

    add dword [SECTOR_OFFSET], FRAME_SIZE ; increment the offset
    ret ; return to caller

disk_error:
    mov bp, DISK_ERROR ; load the address of the error message
    mov cl, ah ; load the error code into the `cl` register

    call print ; print the error message

    call print_hex ; print the error code in hex
    call line_break ; add a line break

    hlt ; halt the system

DISK_ERROR: db "error: disk read failed with code 0x", 0