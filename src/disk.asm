DISK_ADDRESS_PACKET:
    db 0x10 ; size of the packet, 16 bytes by default
    db 0x00 ; unused, should always be 0

    dw FRAME_SIZE ; number of sectors to read
    dw FRAME_OFFSET ; pointer to the buffer
    dw 0x00 ; page number, 0 by default

    BYTE_OFFSET: dd 0x01 ; offset of the sector to read (lower 32-bits)
    dd 0x00 ; unused here (upper 32-bits)

read_frame:
    mov ah, 0x42 ; 'Extended Read Sectors From Drive' function
    mov si, DISK_ADDRESS_PACKET ; load the address of the packet

    int 0x13 ; BIOS interrupt
    jc disk_error ; if carry flag is set, an error occurred

    add dword [BYTE_OFFSET], FRAME_SIZE ; increment the offset
    ret ; return to caller

disk_error:
    mov bx, DISK_ERROR
    call println ; print the error message

    hlt ; halt the system

sector_error:
    mov bx, SECTOR_ERROR
    call println

    hlt ; halt the system

FRAME_SIZE equ 4 ; 4 sectors per frame

DISK_ERROR: db "Disk read error", 0
SECTOR_ERROR: db "Incorrect number of sectors read", 0