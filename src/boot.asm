[bits 64]
default rel                 ; Ensure all labels use RIP-relative addressing
section .text
global _start
extern kernel_main          ; From your kernel.c

_start:
    cli                     ; Pioneer doesn't know to rest
    mov rsp, 0x90000        ; Set 64-bit stack pointer
    
    ; --- 64-bit Paging Setup (Identity Mapping 2MB) ---
    ; Using RDI (64-bit) to avoid relocation truncation
    mov rdi, 0x1000         ; PML4 Base
    mov [rdi], qword 0x2003 ; PML4 -> PDPT
    mov [rdi + 0x1000], qword 0x3003 ; PDPT -> PD
    mov [rdi + 0x2000], qword 0x4003 ; PD -> PT

    ; Fill Page Table (PT)
    mov rbx, 0x00000003     ; Present + Writable
    mov rcx, 512
.set_pt:
    mov [rdi + 0x3000], rbx
    add rbx, 0x1000
    add rdi, 8
    loop .set_pt

    ; --- Load Global Descriptor Table ---
    lgdt [gdt_descriptor]

    ; --- Enter Kernel ---
    ; Everyone isn't same: Your C kernel takes over here
    call kernel_main
    
.halt:
    hlt
    jmp .halt

; --- Data Section inside .text for UEFI simplicity ---
align 16
gdt_start: 
    dq 0x0000000000000000   ; Null Descriptor
    dq 0x00209A0000000000   ; 64-bit Code Segment
    dq 0x0000920000000000   ; 64-bit Data Segment
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dq gdt_start            ; 8-byte base for 64-bit lgdt
