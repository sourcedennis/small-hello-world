# Small Hello World Executables

Simple source code often compiles to needlessly large executable files. Consider a simple Hello World program in C:

```c
#include <stdio.h>

int main( void ) {
  printf( "Hello, World\n" );
  return 0;
}
```

I compiled this program with `gcc` as follows:

```
gcc -s program.c
```
The `-s` flag causes `gcc` to strip symbols from the executable file, making it smaller. On my x86-64 machine, the produced file is still about 14 KiB. When compiled on my Raspberry Pi, the AArch32 executable is still over 5 KiB. Expending *five thousand* bytes to print `Hello, World` seems excessive. Assuming these executables contain a large number of instructions, another Hello World executable with fewer instructions is likely also faster.

Surely, optimizing a Hello World program for both size and space is rather futile. However, this approach hopefully unveils opportunities for optimizing compilers; This may benefit larger realistic programs.

## Programs

The source files assemble into small executable binaries that print `Hello, World` upon execution. Currently, all files produce Linux ELF executables, which target any of the following architectures:

* `program.elf.x86.asm` - targets the (32-bit) x86 instruction set (131 byte binary)
* `program.elf.x64.asm` - targets the (64-bit) x86-64 instruction set (172 byte binary)
* `program.elf.arm32.asm` - targets the AArch32 instruction set (133 byte binary)

All files are written in [NASM](https://nasm.us/) assembly and can be compiled with:

```
nasm -fbin [input] -o [output]
```

### Notes on x86 / x64 system calls

Note that the selected instructions between these programs differ. The `syscall` instruction performs system calls on x86-64 machines, while it is *unavailable* on (32-bit) x86 machines. Instead, the latter uses `int 0x80` to perform system calls. Parameters are also passed differently. That is, different numbers identify the same system call between the two, and those values are passed in different registers. See also: [x86 Assembly/Interfacing with Linux](http://en.wikibooks.org/wiki/X86_Assembly/Interfacing_with_Linux)

### Notes on AArch32

NASM only supports the x86 architecture. However, the alternative GNU Assembler gives little control over the produced files. So, I used the GNU Assembler to find the binary representation of instructions, which I hardcoded in the NASM assembly file; For this, the following two commands are useful:

```
as program.s -o program.o
objdump -D program.o
```
Here, `program.s` is an AArch32 assembly file, containing only instructions (and no ELF specification).

### Notes on debugging ELF

Machines are rather picky about *alignment* of regions in memory. For my machines, alignments of `0x1000` seem to work. Smaller amounts often produce segmentation faults upon execution.

As segfaults may also be caused by malformed ELF files, `readelf` is invaluable for ELF file inspection; which may - for instance - be invoked with:

```
readelf -h -l [file]
```

## Credits

* [A Whirlwind Tutorial on Creating Really Teensy ELF Executables for Linux](https://muppetlabs.com/~breadbox/software/tiny/teensy.html) - The author hacks the ELF format to the utmost to produce a 45-byte ELF executable. While violating the ELF standard, Linux accepts the file.
* [ELF-64 Object File Format](https://uclibc.org/docs/elf-64-gen.pdf)

## License

Public Domain - See the `LICENSE` file

