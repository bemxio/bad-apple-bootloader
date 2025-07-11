IVT_IRQ0_OFFSET equ 0x0020 ; offset of the first IRQ in the IVT
;PIT_RELOAD_VALUE equ 39772 ; reload value for the PIT (0x9b5c, 39772, results in 30 hz/FPS)

setup_pit:
    pusha ; save registers

    mov al, 0x34 ; command byte (channel 0, lobyte/hibyte, rate generator)
    out 0x43, al ; send the command byte to the PIT

    mov ax, PIT_RELOAD_VALUE ; set the reload value
    out 0x40, al ; send the reload value low byte to the PIT

    mov al, ah ; move the high byte to the low byte
    out 0x40, al ; send the reload value high byte to the PIT

    %ifdef VERBOSE_OUTPUT
        mov si, DEBUG_TYPE_PIT ; load the address of the message type
        call print ; print it

        mov si, DEBUG_SUCCESSFUL_INIT ; load the address of the success message
        call print ; print it

        call line_break ; add a line break
    %endif

    popa ; restore registers
    ret ; return from function

setup_ivt:
    pusha ; save registers

    mov word [IVT_IRQ0_OFFSET], pit_handler ; set the PIT handler offset in the IVT
    mov word [IVT_IRQ0_OFFSET + 2], cs ; set the PIT handler segment in the IVT

    %ifdef VERBOSE_OUTPUT
        mov si, DEBUG_TYPE_IVT ; load the address of the message type
        call print ; print it

        mov si, DEBUG_SUCCESSFUL_INIT ; load the address of the success message
        call print ; print it

        call line_break ; add a line break
    %endif

    popa ; restore registers
    ret ; return from function