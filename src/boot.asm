[bits 16]
global start
extern kernel_main

start:
    cli                         ; Disable interrupts
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x9000              ; Set stack pointer safely away from 0x7c00

    ; Enable A20 Gate for full memory access
    in al, 0x92
    or al, 2
    out 0x92, al

    lgdt [gdt_descriptor]       ; Load Global Descriptor Table
    mov eax, cr0
    or eax, 0x1                 ; Switch to 32-bit Protected Mode
    mov cr0, eax
    jmp 0x08:init_pm            ; Far jump to clear pipeline

[bits 32]
init_pm:
    mov ax, 0x10
    mov ds, ax
    mov ss, ax
    mov es, ax
    call kernel_main            ; Jump to our C Kernel
    jmp $                       ; Infinite hang if kernel returns

gdt_start: dq 0x0
gdt_code:  dw 0xffff, 0x0, 0x9a, 0xcf
gdt_data:  dw 0xffff, 0x0, 0x92, 0xcf
gdt_end:
gdt_descriptor: dw gdt_end - gdt_start - 1
                dd gdt_start

times 510-($-$$) db 0           ; Pad to 510 bytes
dw 0xaa55                       ; Boot signature
