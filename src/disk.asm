DISK_ERROR_MESSAGE: db "Error: Disk read failed with code 0x", 0x00

DRIVE_NUMBER: db 0x80 ; main hard drive
CHUNK_SIZE equ 64 ; 64 sectors (32,768 bytes) per chunk
;FRAME_AMOUNT equ 6569 ; 6569 frames (03:38 with 30 FPS)

DISK_ADDRESS_PACKET:
    db 0x10 ; size of the packet (16 bytes)
    db 0x00 ; unused byte, always 0

    dw CHUNK_SIZE ; number of sectors to read
    dw 0x7e00 ; buffer offset
    dw 0x00 ; buffer segment

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
    mov si, DISK_ERROR_MESSAGE ; load the address of the error message
    mov cl, ah ; load the error code

    call print ; print the error message
    call print_hex ; print the error code in hex
    call line_break ; add a line break

    hlt ; halt the system