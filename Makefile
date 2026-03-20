# --- PIONEER OS 64-BIT FORGE ---
TARGET = BOOTX64.EFI
AS = nasm
CC = gcc
LD = ld

# 64-bit UEFI-compatible flags
CFLAGS = -m64 -ffreestanding -fno-stack-protector -fno-stack-check -nostdlib -mno-red-zone
# Use the 'i386pep' emulation for 64-bit PE (Windows/UEFI compatible)
LDFLAGS = -m i386pep --subsystem 10 --entry _start

OBJS = boot.o kernel.o

all: $(TARGET)

# Compile boot.asm as a 64-bit win64 object (compatible with PE/COFF)
boot.o: src/boot.asm
	$(AS) -f win64 src/boot.asm -o boot.o

kernel.o: src/kernel.c
	$(CC) $(CFLAGS) -c src/kernel.c -o kernel.o

$(TARGET): $(OBJS)
	$(LD) $(LDFLAGS) $(OBJS) -o $(TARGET)

clean:
	rm -f *.o $(TARGET)
