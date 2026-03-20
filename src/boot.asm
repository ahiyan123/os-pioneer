[bits 16]
real_start:
    cli
    ; ... (Previous segment/stack setup) ...
    lgdt [gdt_descriptor]
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    jmp 0x08:init_pm

[bits 32]
init_pm:
    mov ax, 0x10
    mov ds, ax
    mov ss, ax

    ; 1. Setup Page Tables (Zero out 0x1000 to 0x5000)
    ; PML4 -> PDPT -> PD -> PT
    mov edi, 0x1000    ; Table location
    cr3, edi           ; Point CPU to PML4
    
    ; Simple Identity Map (First 2MB)
    mov dword [0x1000], 0x2003      ; PML4 -> PDPT
    mov dword [0x2000], 0x3003      ; PDPT -> PD
    mov dword [0x3000], 0x4003      ; PD -> PT
    
    ; Fill PT with 512 entries (mapping 2MB)
    mov ebx, 0x00000003
    mov ecx, 512
.set_pt:
    mov [edi + 0x3000], ebx
    add ebx, 0x1000
    add edi, 8
    loop .set_pt

    ; 2. Enable PAE
    mov eax, cr4
    or eax, 1 << 5
    mov cr4, eax

    ; 3. Enable Long Mode in EFER MSR
    mov ecx, 0xC0000080
    rdmsr
    or eax, 1 << 8
    wrmsr

    ; 4. Enable Paging (The Final Jump)
    mov eax, cr0
    or eax, 1 << 31
    mov cr0, eax

    jmp 0x08:init_lm

[bits 64]
init_lm:
    ; You are now in 64-bit Long Mode.
    ; Your Sovereign Apps can now use RAX, RBX, etc.
    extern kernel_main
    call kernel_main
    jmp $

; Updated GDT for 64-bit
gdt_start: dq 0
gdt_code:  dq 0x00209A0000000000 ; 64-bit Code Segment
gdt_data:  dq 0x0000920000000000 ; 64-bit Data Segment
gdt_end:
gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dq gdt_start
