# Assembly Pong Game

This project implements the classic game Pong in x86 assembly language, complete with a custom bootloader. The game runs in 32-bit protected mode and provides a fun, retro gaming experience while showcasing low-level programming techniques.

## Project Structure

```
.
├── Makefile
├── boot/
│   ├── boot.asm
│   ├── disk.asm
│   ├── gdt.asm
│   ├── print.asm
│   └── switch_pm.asm
└── game.asm
```

- `boot/`: Contains the bootloader and related assembly files
- `game.asm`: The main Pong game implementation
- `Makefile`: Automates the build process

## Components

### Bootloader

The bootloader is responsible for:
1. Loading the kernel (our game) from disk
2. Setting up the Global Descriptor Table (GDT)
3. Switching the CPU to 32-bit protected mode
4. Transferring control to the game code

Key files:
- `boot.asm`: Main bootloader code
- `gdt.asm`: Defines the Global Descriptor Table
- `switch_pm.asm`: Handles the switch to 32-bit protected mode

### Game (game.asm)

The `game.asm` file contains the entire Pong game implementation, including:
- Game initialization
- Main game loop
- Input handling
- Game state updates
- Screen rendering
- Score tracking

## Dependencies

To build and run this project, you'll need:

1. NASM (Netwide Assembler)
2. GNU Make
3. QEMU (for emulation)
4. GCC cross-compiler for i386 (for linking)

### Setup on Ubuntu/Debian

```bash
sudo apt update
sudo apt install nasm make qemu-system-x86 gcc-multilib
```

### Setup on macOS

1. Install Homebrew if not already installed:
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

2. Install dependencies:
   ```bash
   brew install nasm make qemu x86_64-elf-gcc
   ```

### Setup on Windows

1. Install WSL (Windows Subsystem for Linux) and Ubuntu
2. Follow the Ubuntu/Debian setup instructions within WSL

## Building the Project

1. Clone the repository:
   ```bash
   git clone https://github.com/pxd222PranavDhinakar/pong
   cd pong
   ```

2. Build the project:
   ```bash
   make
   ```

This will compile the bootloader and game, linking them into a single bootable disk image.

## Running the Game

To run the game in QEMU:

```bash
make run
```

This command will start QEMU and boot your Pong game.

## Playing the Game

- Press the spacebar to start the game
- Left paddle controls: 
  - 'W' key to move up
  - 'S' key to move down
- Right paddle controls:
  - Up arrow to move up
  - Down arrow to move down

## Modifying the Game

- `game.asm`: Contains the main game logic. Modify this file to change game behavior, add features, or adjust difficulty.
- `boot/boot.asm`: Bootloader code. Be cautious when modifying this, as it's crucial for loading the game correctly.

## Troubleshooting

- If you encounter "Operation not permitted" errors when running `make`, ensure you have the necessary permissions or try running with `sudo`.
- If QEMU fails to start, verify that it's correctly installed and in your system's PATH.
- For linking errors, make sure you have the correct cross-compiler installed for your system.


