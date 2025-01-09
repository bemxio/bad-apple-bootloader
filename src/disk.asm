DISK_ERROR_MESSAGE: db "Error: Disk read failed with code 0x", 0x00

DRIVE_NUMBER: db 0x80 ; main hard drive
FRAME_SIZE equ 125 ; 125 sectors (64,000 bytes) per frame
;FRAME_AMOUNT equ 6569 ; 6569 frames (03:38 with 30 FPS)

DISK_ADDRESS_PACKET:
    db 0x10 ; size of the packet (16 bytes)
    db 0x00 ; unused byte, always 0

    dw FRAME_SIZE ; number of sectors to read
    dw 0x00 ; buffer address
    dw 0xa000 ; buffer segment

    BYTE_OFFSET: dd 0x01 ; byte offset (lower 32-bits)
    dd 0x00 ; byte offset (upper 32-bits)

read_frame:
    pusha ; save registers

    mov ah, 0x42 ; 'Extended Read Sectors From Drive' function
    mov si, DISK_ADDRESS_PACKET ; load the address of the packet
    mov dl, byte [DRIVE_NUMBER] ; load the drive number

    int 0x13 ; BIOS interrupt
    jc disk_error ; if carry flag is set, an error occurred

    add dword [BYTE_OFFSET], FRAME_SIZE ; increment the byte offset

    popa ; restore registers
    ret ; return from function

disk_error:
    mov si, DISK_ERROR_MESSAGE ; load the address of the error message
    mov cl, ah ; load the error code

    call print ; print the error message
    call print_hex ; print the error code in hex
    call line_break ; add a line break

    hlt ; halt the system