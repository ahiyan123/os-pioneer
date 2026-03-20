TARGET = BOOTX64.EFI
AS = nasm
CC = gcc
LD = ld

CFLAGS = -m64 -ffreestanding -fno-stack-protector -nostdlib -mno-red-zone
LDFLAGS = -m i386pep --subsystem 10 --entry _start

all: $(TARGET)

boot.o: src/boot.asm
	$(AS) -f win64 src/boot.asm -o boot.o

kernel.o: src/kernel.c
	$(CC) $(CFLAGS) -c src/kernel.c -o kernel.o

$(TARGET): boot.o kernel.o
	$(LD) $(LDFLAGS) boot.o kernel.o -o $(TARGET)
