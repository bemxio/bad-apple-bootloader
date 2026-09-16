DSP_RESET equ 0x226
DSP_READ equ 0x22a
DSP_WRITE equ 0x22c
DSP_READ_STATUS equ 0x22f

IVT_IRQ5_OFFSET equ 0x0034 ; offset of the fifth IRQ in the IVT
AUDIO_CHUNK_SIZE equ 32 ; 32 sectors (16,384 bytes) per chunk

AUDIO_ADDRESS_PACKET:
    db 0x10 ; size of the packet (16 bytes)
    db 0x00 ; unused byte, always 0

    dw AUDIO_CHUNK_SIZE ; number of sectors to read
    AUDIO_BUFFER_OFFSET: dw 0x0000 ; buffer offset
    dw 0x1000 ; buffer segment

    AUDIO_SECTOR_OFFSET: dd 0x01 ; sector offset (lower 32-bits)
    dd 0x00 ; sector offset (upper 32-bits)

setup_sb16:
    pusha ; save registers

    ; reset the sound card
    outb DSP_RESET, 1 ; send 1 to the DSP reset port

    mov ah, 0x86 ; 'Wait' function
    xor cx, cx ; clear upper 16-bits of the delay
    mov dx, 0x3e8 ; 1000 microseconds (1 millisecond)

    int 0x15 ; BIOS interrupt

    outb DSP_RESET, 0 ; send 0 to the DSP reset port
    inb DSP_READ ; read the status port

    cmp al, 0xaa ; check if the sound card is present
    jne sb16_error ; if not, jump to error handling

    ; set up the IRQ
    cli ; disable interrupts

    inb 0x21 ; read the PIC mask register
    and al, 0xdf ; clear bit 5 (0xDF = 11011111b)
    out 0x21, al ; write the new mask register value
 
    mov word [IVT_IRQ5_OFFSET], sb16_handler ; set the handler offset in the IVT
    mov word [IVT_IRQ5_OFFSET + 2], cs ; set the handler segment

    sti ; re-enable interrupts

    ; turn on the speaker
    outb DSP_WRITE, 0xd1 ; send 'Turn on speaker' command to the DSP write port

    ; configure ISA DMA channel 5
    outb 0xd4, 0x05 ; temporarily disable DMA channel 5
    outb 0xd8, 1 ; activate flip-flop reset register
    outb 0xd6, 0b01011001 ; single DMA transfer, reading from memory, channel 5

    outb 0x8b, 0x00 ; page number
    outb 0xc4, 0x00 ; low word of the address
    outb 0xc4, 0x80 ; high word of the address

    outb 0xc6, 0xff ; low word of the count
    outb 0xc6, 0x3f ; high word of the count

    outb 0xd4, 0x01 ; re-enable DMA channel 5

    ; configure sound card
    outb DSP_WRITE, 0x41 ; send 'Set sample rate' command to the DSP write port
    outb DSP_WRITE, 0xac ; high byte of the sample rate (44100 Hz)
    outb DSP_WRITE, 0x44 ; low byte of the sample rate

    outb DSP_WRITE, 0xb6 ; 16-bit transfer, playing sound, auto initialize mode, FIFO enabled
    outb DSP_WRITE, 0b00110000 ; signed stereo
    outb DSP_WRITE, 0xff ; low word of the transfer length
    outb DSP_WRITE, 0x1f ; high word of the transfer length

    ; read first initial two chunks
    mov si, AUDIO_ADDRESS_PACKET ; load the address of the packet

    call read_chunk ; read a chunk of data from the disk
    add dword [AUDIO_SECTOR_OFFSET], AUDIO_CHUNK_SIZE ; increment the sector offset
    mov word [AUDIO_BUFFER_OFFSET], AUDIO_CHUNK_SIZE * 512 ; set the buffer offset

    call read_chunk ; read a second chunk of data from the disk
    add dword [AUDIO_SECTOR_OFFSET], AUDIO_CHUNK_SIZE ; increment the sector offset
    mov word [AUDIO_BUFFER_OFFSET], 0 ; set the buffer offset

    popa ; restore registers
    ret ; return from function

sb16_handler:
    pusha ; save registers

    ; acknowledge the interrupt
    inb DSP_READ_STATUS ; read the status port

    ; read the next chunk of audio data from the disk
    mov si, AUDIO_ADDRESS_PACKET ; load the address of the packet

    call read_chunk ; read a chunk of data from the disk
    add dword [AUDIO_SECTOR_OFFSET], AUDIO_CHUNK_SIZE ; increment the sector offset

    cmp word [AUDIO_BUFFER_OFFSET], 0 ; check if the buffer offset is 0
    jne sb16_handler_reset ; if not, jump to reset the buffer offset

    mov word [AUDIO_BUFFER_OFFSET], AUDIO_CHUNK_SIZE * 512 ; set the buffer offset
    jmp sb16_handler_end ; jump to the end of the handler

    sb16_handler_reset:
        mov word [AUDIO_BUFFER_OFFSET], 0 ; reset the buffer offset

    sb16_handler_end:
        mov al, 0x20 ; EOI signal
        out 0x20, al ; send the signal to the PIC

        popa ; restore registers
        iret ; return from interrupt

sb16_error:
    %ifndef SIZE_OPTIMIZED
        mov si, SB16_ERROR_MESSAGE ; load the address of the error message
        mov cl, al ; load the error code

        call print ; print the error message
        call print_hex ; print the error code in hex
        call line_break ; add a line break
    %endif

    hlt ; halt the system