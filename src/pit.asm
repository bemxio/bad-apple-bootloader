IVT_IRQ0_OFFSET equ 0x0020 ; the offset of the first IRQ in the IVT
;PIT_RELOAD_VALUE equ 0x9b5c ; the reload value for the PIT (0x9b5c, 39772, results in 30 hz/FPS)

setup_pit:
    pusha ; save the registers

    mov al, 0x34 ; set the command byte (channel 0, lobyte/hibyte, rate generator)
    out 0x43, al ; send the command byte to the PIT

    mov ax, PIT_RELOAD_VALUE ; set the reload value

    out 0x40, al ; send the low byte to the PIT

    mov al, ah ; move the high byte to the low byte
    out 0x40, al ; send the high byte to the PIT

    popa ; restore the registers
    ret ; return to caller

setup_ivt:
    pusha ; save the registers

    mov word [IVT_IRQ0_OFFSET], pit_handler ; set the PIT handler offset in the IVT
    mov word [IVT_IRQ0_OFFSET + 2], 0x00 ; set the PIT handler segment in the IVT

    popa ; restore the registers
    ret ; return to caller