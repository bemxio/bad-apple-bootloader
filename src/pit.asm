IVT_IRQ0_OFFSET equ 0x0020 ; offset of the first IRQ in the IVT

setup_pit:
    pusha ; save registers

    cli ; disable interrupts

    ; configure PIT for generating interrupts
    mov al, 0x34 ; command byte (channel 0, lobyte/hibyte, rate generator)
    out 0x43, al ; send the command byte to the PIT

    mov ax, PIT_RELOAD_VALUE ; set the reload value
    out 0x40, al ; send the reload value low byte to the PIT

    mov al, ah ; move the high byte to the low byte
    out 0x40, al ; send the reload value high byte to the PIT

    ; add the interrupt handler to the IVT
    mov word [IVT_IRQ0_OFFSET], pit_handler ; set the handler offset in the IVT
    mov word [IVT_IRQ0_OFFSET + 2], cs ; set the handler segment in the IVT

    sti ; re-enable interrupts

    popa ; restore registers
    ret ; return from function