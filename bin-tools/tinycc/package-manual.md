# TinyCC - Tiny C Compiler Package

Self-contained, ultra-fast C compiler for PORTX. Perfect for building native C applications.

## Features
- **Ultra-fast compilation**: 9x faster than GCC
- **Self-contained**: Complete C compiler in ~100KB
- **Native Windows**: Pure Windows executable, no dependencies
- **Complete toolchain**: Compiler, assembler, linker in one executable

## Usage
```bash
# Compile and run directly
tcc -run program.c

# Compile to executable
tcc -o program.exe program.c

# Link with Windows libraries
tcc -o program.exe program.c -luser32 -lkernel32
```

## Components
- `tcc.exe` - Main C compiler
- `tiny_impdef.exe` - Import definition generator  
- `tiny_libmaker.exe` - Library maker
- `libtcc.dll` - TCC library for embedding
- `include/` - Complete Windows headers
- `lib/` - Windows import libraries

## Perfect for PORTX
TCC exemplifies PORTX principles: self-contained, portable, no external dependencies.