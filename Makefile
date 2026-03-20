# --- PIONEER OS ROOT FORGE ---
TARGET = pioneer_os.bin
CC = gcc
AS = nasm
LD = ld

# Flags for 32-bit Bare Metal
CFLAGS = -m32 -ffreestanding -O2 -fno-pie -fno-stack-protector -nostdlib -Isrc
LDFLAGS = -m elf_i386 -T src/linker.ld --oformat binary

# Objects stay in the root for easy cleanup
OBJS = boot.o kernel.o

all: $(TARGET)
	@echo "Forge Complete: $(TARGET) created from src/ components."

# Reach into src/ for the assembly
boot.o: src/boot.asm
	$(AS) -f elf32 src/boot.asm -o boot.o

# Reach into src/ for the C kernel
kernel.o: src/kernel.c
	$(CC) $(CFLAGS) -c src/kernel.c -o kernel.o

# Link using the linker script inside src/
$(TARGET): $(OBJS) src/linker.ld
	$(LD) $(LDFLAGS) $(OBJS) -o $(TARGET)

clean:
	rm -f *.o $(TARGET)
