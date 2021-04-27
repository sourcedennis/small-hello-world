BITS 64

; ELF header
ehdr:
          db    0x7F, "ELF"         ; magic
          db    2                   ; 64-bit
          db    1                   ; little endian
          db    1                   ; ELF version, always 1
          db    0x03                ; target Linux
  times 8 db    0                   ; padding
          dw    0x02                ; executable
          dw    0x3E                ; x86-64 machine
          dd    0x01                ; ELF version, always 1
          dq    _start              ; execution entry (in memory)
          dq    phdr-ehdr           ; program header (in file)
          dq    0                   ; section header table
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
          dd    5                   ; read+execute segment
          dq    codestart           ; segment content offset (in file) 
          dq    _start              ; virtual address in memory
          dq    _start              ; physical address in memory
          dq    codesegsize         ; size in the file
          dq    codesegsize         ; size in memory
          dq    0x1000              ; alignment

phdrsize  equ   $ - phdr
codestart equ   $ - ehdr


; Code segment
_start:
          org 0x400000
          ; the file start is at memory location 0x400000
          ; the code loads at 0x400078. this is necessary to ensure 0x1000
          ; alignment. (on my machine, lower alignments give segfaults)

          mov rax, 1
          mov rdi, 1
          mov rsi, msg
          mov rdx, msglen
          syscall
          mov rax, 60
          mov rdi, 0
          syscall

; data
msg:         db    "Hello, World",10
msglen       equ   $ - msg

codesegsize  equ   $ - _start 

