FRAME_SIZE equ 125 ; 125 sectors (64,000 bytes) per frame

DISK_ADDRESS_PACKET:
    db 0x10 ; size of the packet (16 bytes)
    db 0x00 ; unused byte, always 0

    dw FRAME_SIZE ; number of sectors to read
    dw 0x0000 ; buffer address
    dw 0xa000 ; buffer segment

    BYTE_OFFSET: dd 0x01 ; byte offset (lower 32-bits)
    dd 0x00 ; byte offset (upper 32-bits)

read_frame:
    pusha ; save registers

    mov ah, 0x42 ; 'Extended Read Sectors From Drive' function
    mov si, DISK_ADDRESS_PACKET ; load the address of the packet

    int 0x13 ; BIOS interrupt
    jc disk_error ; if carry flag is set, an error occurred

    add dword [BYTE_OFFSET], FRAME_SIZE ; increment the byte offset

    popa ; restore registers
    ret ; return from function

disk_error:
    mov si, DISK_ERROR_MESSAGE ; load the address of the error message
    mov cl, ah ; load the error code

    mov ax, 0x02 ; 'Set Video Mode' function with 80x25 text mode
    int 0x10 ; call the BIOS interrupt

    call print ; print the error message
    call print_hex ; print the error code in hex
    call line_break ; add a line break

    hlt ; halt the system

DISK_ERROR_MESSAGE: db "Error: Disk read failed with code 0x", 0x00