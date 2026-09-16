DRIVE_NUMBER: db 0x80 ; main hard drive

read_chunk:
    pusha ; save registers

    mov ah, 0x42 ; 'Extended Read Sectors From Drive' function
    mov dl, byte [DRIVE_NUMBER] ; load the drive number
    ;mov si, DISK_ADDRESS_PACKET ; load the address of the packet

    int 0x13 ; BIOS interrupt
    jc disk_error ; if carry flag is set, an error occurred

    ;add dword [SECTOR_OFFSET], CHUNK_SIZE ; increment the sector offset by the chunk size

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