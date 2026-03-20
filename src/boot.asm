[bits 64]
default rel                 ; Force RIP-relative addressing for win64 relocations

section .text
global _start
extern kernel_main          ; Linked from your 64-bit kernel.c

_start:
    cli                     ; Pioneer doesn't know to rest
    mov rsp, 0x90000        ; Initialize a stable 64-bit stack

    ; --- 64-bit Paging Setup (Identity Mapping 2MB) ---
    ; Using explicit qword sizes to satisfy NASM win64 requirements
    mov rdi, 0x1000         ; PML4 Base Address
    mov qword [rdi], 0x2003          ; PML4[0] points to PDPT at 0x2000
    mov qword [rdi + 0x1000], 0x3003 ; PDPT[0] points to PD at 0x3000
    mov qword [rdi + 0x2000], 0x4003 ; PD[0] points to PT at 0x4000

    ; Fill Page Table (PT) to map first 2MB of the 1.9GB JetFlash
    mov rbx, 0x00000003     ; Present + Writable bits
    mov rcx, 512            ; 512 entries * 4KB = 2MB
    lea rdi, [rdi + 0x3000] ; Point RDI to the start of the PT
.set_pt:
    mov qword [rdi], rbx
    add rbx, 0x1000
    add rdi, 8
    loop .set_pt

    ; --- Load Global Descriptor Table ---
    lgdt [gdt_descriptor]

    ; --- Jump to Sovereign Kernel ---
    ; Everyone isn't same: Enter your C logic
    call kernel_main
    
.halt:
    hlt
    jmp .halt

; --- Data Section (Internal to .text for PE alignment) ---
align 16
gdt_start: 
    dq 0x0000000000000000   ; Null Descriptor
    dq 0x00209A0000000000   ; 64-bit Code Segment (Long Mode)
    dq 0x0000920000000000   ; 64-bit Data Segment
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dq gdt_start            ; 8-byte base address for 64-bit LGDT
