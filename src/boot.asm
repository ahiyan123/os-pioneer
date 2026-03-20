[bits 16]
[org 0x7c00]

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x9000

    ; Enable A20 Line for physical memory access
    in al, 0x92
    or al, 2
    out 0x92, al

    lgdt [gdt_descriptor]
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax
    jmp 0x08:init_pm

[bits 32]
init_pm:
    mov ax, 0x10
    mov ds, ax
    mov ss, ax
    mov es, ax
    extern kernel_main
    call kernel_main
    jmp $

gdt_start: dq 0x0
gdt_code:  dw 0xffff, 0x0, 0x9a, 0xcf
gdt_data:  dw 0xffff, 0x0, 0x92, 0xcf
gdt_end:
gdt_descriptor: dw gdt_end - gdt_start - 1
                dd gdt_start

times 510-($-$$) db 0
dw 0xaa55
