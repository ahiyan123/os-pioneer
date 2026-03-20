[bits 16]
global start
extern kernel_main

start:
    jmp short real_start
    nop

; --- FAT32 BPB for 1.9GB Drive ---
oem_name           db "PIONEER "
bytes_per_sector   dw 512
sectors_per_cluster db 8
reserved_sectors    dw 32
fat_count          db 2
root_entries       dw 0
total_sectors_16   dw 0
media_type         db 0xF8
fat_size_16        dw 0
sectors_per_track  dw 32
head_count         dw 64
hidden_sectors     dd 0
total_sectors_32   dd 3906250       ; 1.9 GB Limit
fat_size_32        dd 3800
ext_flags          dw 0
fs_version         dw 0
root_cluster       dd 2
fs_info            dw 1
backup_boot        dw 6
times 12 db 0
drive_num          db 0x80
nt_res             db 0
boot_sig           db 0x29
volume_id          dd 0x12345678
volume_label       db "PIONEER OS "
system_id          db "FAT32   "

real_start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x9000
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
