# Compiler and linker
ASM = nasm
LD = x86_64-elf-ld

# Flags
ASMFLAGS = -f elf32
LDFLAGS = -m elf_i386 -Ttext 0x1000 --oformat binary

# Source and output files
BOOT_SRC = boot/boot.asm
KERNEL_SRC = game.asm
OS_IMAGE = os-image.bin
KERNEL_BIN = kernel.bin
BOOT_BIN = boot/boot.bin

# Default target
all: $(OS_IMAGE)

# Create the final OS image
$(OS_IMAGE): $(BOOT_BIN) $(KERNEL_BIN)
	cat $^ > $@

# Compile the kernel
$(KERNEL_BIN): $(KERNEL_SRC)
	$(ASM) $(ASMFLAGS) $< -o $(basename $<).o
	$(LD) $(LDFLAGS) -o $@ $(basename $<).o

# Compile the bootloader
$(BOOT_BIN): $(BOOT_SRC)
	$(ASM) -f bin $< -o $@

# Run QEMU
run: $(OS_IMAGE)
	qemu-system-i386 -fda $<

# Clean up
clean:
	rm -f *.bin *.o $(OS_IMAGE)
	rm -f boot/*.bin

.PHONY: all run clean
