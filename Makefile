# --- PIONEER OS MASTER FORGE ---
# Motto: Pioneer doesn't know to rest.
# Values: Everyone isn't same.

# Toolchain (i686-elf cross-compiler for MSYS2)
CC = i686-elf-gcc
AS = nasm
LD = i686-elf-ld

# Flags
# -ffreestanding: We are the OS, no host libraries allowed.
# -O2: Optimize for the "Pioneer" speed.
# -Wall -Wextra: Show every warning; pioneers don't ignore errors.
CFLAGS = -std=gnu99 -ffreestanding -O2 -Wall -Wextra
LDFLAGS = -T linker.ld --oformat binary

# Project Files
TARGET = pioneer_os.bin
OBJS = boot.o kernel.o

# --- BUILD RULES ---

all: $(TARGET)
	@echo "------------------------------------------------"
	@echo "PIONEER OS FORGED SUCCESSFULLY"
	@echo "Final Size: $$(stat -c%s $(TARGET)) bytes"
	@echo "Sectors Used: $$(($$(stat -c%s $(TARGET)) / 512 + 1))"
	@echo "------------------------------------------------"

# Assemble the Bootloader (The 16-bit to 32-bit Gateway)
boot.o: boot.asm
	$(AS) -f elf32 boot.asm -o boot.o

# Compile the Unified Kernel (Apps + Drivers + GUI)
kernel.o: kernel.c
	$(CC) -c kernel.c -o kernel.o $(CFLAGS)

# Link into the Sovereign Binary
$(TARGET): $(OBJS) linker.ld
	$(LD) $(LDFLAGS) $(OBJS) -o $(TARGET)

# Clean the Forge
clean:
	rm -f *.o $(TARGET)

# Flash Helper (Information Only)
flash-info:
	@echo "To flash to USB, run the PowerShell script as Admin."
	@echo "Target Device: PhysicalDriveX (Check Disk Management)"
