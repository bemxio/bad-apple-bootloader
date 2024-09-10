FRAME_SIZE equ 4 ; 4 sectors per frame

HEADS_PER_CYLINDER equ 0x10 ; 16 heads per cylinder
SECTORS_PER_TRACK equ 0x3F ; 63 sectors per track

CYLINDER_OFFSET db 0x00 ; cylinder number (low 8 bits)
HEAD_OFFSET db 0x00 ; head number
SECTOR_OFFSET db 0x01 ; sector number (6 bits)

increment_address:
    add byte [SECTOR_OFFSET], FRAME_SIZE ; increment the offset

    cmp byte [SECTOR_OFFSET], SECTORS_PER_TRACK ; compare the offset to the number of sectors per track
    jl check_head ; if less, check the head number

    sub byte [SECTOR_OFFSET], SECTORS_PER_TRACK ; subtract the number of sectors per track from the offset
    inc byte [HEAD_OFFSET] ; increment the head number

check_head:
    cmp byte [HEAD_OFFSET], HEADS_PER_CYLINDER ; compare the head number to the number of heads per cylinder
    jl end_incrementation ; if less, we're done

    mov byte [HEAD_OFFSET], 0x00 ; reset the head number
    inc byte [CYLINDER_OFFSET] ; increment the cylinder number

end_incrementation:
    ret ; return from function

read_frame:
    pusha ; save registers

    mov ah, 0x02 ; 'Read Sectors From Drive' function

    xor bx, bx ; clear the `bx` register
    mov es, bx ; set the segment to read to (always 0)

    mov al, FRAME_SIZE ; set the number of sectors to read
    mov bx, FRAME_ADDRESS ; load the address to read to

    mov ch, byte [CYLINDER_OFFSET] ; load the cylinder number
    mov dh, byte [HEAD_OFFSET] ; load the head number

    mov cl, byte [SECTOR_OFFSET] ; load the sector number
    inc cl ; increment the sector number (sectors are 1-indexed)

    int 0x13 ; BIOS interrupt
    jc disk_error ; if carry flag is set, an error occurred

    call increment_address ; increment the address

    popa ; restore registers
    ret ; return from function

disk_error:
    mov bp, DISK_ERROR_MESSAGE ; load the address of the error message
    mov cl, ah ; load the error cod

    call print ; print the error message
    call print_hex ; print the error code in hex
    call line_break ; add a line break

    hlt ; halt the system

DISK_ERROR_MESSAGE: db "Error: Disk read failed with code 0x", 0x00