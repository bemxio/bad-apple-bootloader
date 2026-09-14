DSP_RESET equ 0x226
DSP_READ equ 0x22a
DSP_WRITE equ 0x22c
DSP_READ_STATUS equ 0x22e

IVT_IRQ5_OFFSET equ 0x0034 ; offset of the fifth IRQ in the IVT

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

    ; configure ISA DMA channel 1
    outb 0x0a, 0x05 ; temporarily disable DMA channel 1
    outb 0x0c, 1 ; activate flip-flop reset register
    outb 0x0b, 0b01011001 ; single DMA transfer, reading from memory, channel 1

    outb 0x83, 0x0a ; page number
    outb 0x02, 0x00 ; low byte of the address
    outb 0x02, 0x00 ; high byte of the address

    outb 0x03, 0x00 ; low byte of the count
    outb 0x03, 0xfa ; high byte of the count

    outb 0x0a, 0x01 ; re-enable DMA channel 1

    ; configure sound card
    outb DSP_WRITE, 0x41 ; send 'Set sample rate' command to the DSP write port
    outb DSP_WRITE, 0x56 ; high byte of the sample rate (22050 Hz)
    outb DSP_WRITE, 0x22 ; low byte of the sample rate

    outb DSP_WRITE, 0xc6 ; 8-bit transfer, playing sound, auto initialize mode, FIFO enabled
    outb DSP_WRITE, 0x00 ; unsigned mono
    outb DSP_WRITE, 0xff ; low byte of the transfer length
    outb DSP_WRITE, 0xf9 ; high byte of the transfer length

    popa ; restore registers
    ret ; return from function

sb16_handler:
    pusha ; save registers

    ; acknowledge the interrupt
    inb DSP_READ_STATUS ; read the status port

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