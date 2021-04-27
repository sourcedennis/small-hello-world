; ELF header
ehdr:
          db    0x7F, "ELF"         ; magic
          db    1                   ; 32-bit
          db    1                   ; little endian
          db    1                   ; ELF version, always 1
          db    0x03                ; target Linux
  times 8 db    0                   ; padding
          dw    0x02                ; executable
          dw    0x28                ; ARM 32-bit
          dd    0x01                ; ELF version, always 1
          dd    _start              ; execution entry (in memory)
          dd    phdr-ehdr           ; program header (in file)
          dd    0                   ; section header table
          dd    0                   ; flags
          dw    ehdrsize            ; size of this ELF header
          dw    phdrsize            ; size of the program header table entry
          dw    1                   ; number of program headers
          dw    0                   ; size of the section header table entry
          dw    0                   ; number of sections headers
          dw    0                   ; name section index: no names section 

ehdrsize  equ   $ - ehdr


; Program header
phdr:
          dd    0x01                ; loadable segment
          dd    codestart           ; segment content offset (in file) 
          dd    _start              ; virtual address in memory
          dd    _start              ; physical address in memory
          dd    codesegsize         ; size in the file
          dd    codesegsize         ; size in memory
          dd    5                   ; read+execute segment
          dd    0x1000              ; alignment

phdrsize  equ   $ - phdr
codestart equ   $ - ehdr


; Code segment
_start:
          org 0x400000
          ; the file start is at memory location 0x400000
          ; the code loads at 0x400054. this is necessary to ensure 0x1000
          ; alignment. (on my machine, lower alignments give segfaults)

          ; NASM supports only x86/x86-64 assembly, not ARM. As the GNU Assembler
          ; does not (seem to) allow the same binary control for specifying ELF files,
          ; I specified the binary instructions manually.

          dd 0xE3A00001             ; mov r0, #1        - stdout
          dd 0xE3A01501             ; mov r1, #0x400000 - message pointer (0x400078)
          dd 0xE3811078             ; orr r1, #0x78     - message pointer
          dd 0xE3A0200D             ; mov r2, #13       - message length
          dd 0xE3A07004             ; mov r7, #4        - system call number for write
          dd 0xEF000000             ; swi 0             - perform the write

          dd 0xE3A00000             ; mov r0, #0  - exit code (success)
          dd 0xE3A07001             ; mov r7, #1  - system call number for exit
          dd 0xEF000000             ; swi 0       - perform the exit 

; data (fixed at 0x400045)
msg:      db "Hello, World",10

codesegsize  equ   $ - _start 
filesize     equ   $ - $$

