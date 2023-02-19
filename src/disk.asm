read_frame:
    mov ah, 0x02 ; 'Read Sectors From Drive' function
    mov al, FRAME_SIZE ; number of sectors to read

    mov cl, 0x02 ; sector
    mov ch, 0x00 ; cylinder
    mov dh, 0x00 ; head

    int 0x13 ; BIOS interrupt
    jc disk_error ; if carry flag is set, an error occurred

    cmp al, FRAME_SIZE ; check if we read all sectors
    jne sector_error ; if not, an error occurred

    ret ; return to caller

disk_error:
    mov bx, DISK_ERROR
    call println ; print the error message

    hlt ; halt the system

sector_error:
    mov bx, SECTOR_ERROR
    call print

    hlt ; halt the system

FRAME_SIZE equ 4 ; 4 sectors per frame

DISK_ERROR: db "Disk read error", 0
SECTOR_ERROR: db "Incorrect number of sectors read", 0