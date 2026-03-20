TARGET = BOOTX64.EFI
AS = nasm
CC = gcc
LD = ld

CFLAGS = -m64 -ffreestanding -fno-stack-protector -nostdlib -mno-red-zone
# Update your LDFLAGS to include these specific UEFI alignments
LDFLAGS = -m i386pep \
          --subsystem 10 \
          --entry _start \
          --stack 0x1000000,0x1000000 \
          --section-alignment 0x1000 \
          --file-alignment 0x200 \
          --image-base 0x400000

all: $(TARGET)

boot.o: src/boot.asm
	$(AS) -f win64 src/boot.asm -o boot.o

kernel.o: src/kernel.c
	$(CC) $(CFLAGS) -c src/kernel.c -o kernel.o

$(TARGET): boot.o kernel.o
	$(LD) $(LDFLAGS) boot.o kernel.o -o $(TARGET)
