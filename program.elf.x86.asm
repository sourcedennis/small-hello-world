BITS 32

; ELF header
ehdr:
          db    0x7F, "ELF"         ; magic
          db    1                   ; 32-bit
          db    1                   ; little endian
          db    1                   ; ELF version, always 1
          db    0x03                ; target Linux
  times 8 db    0                   ; padding
          dw    0x02                ; executable
          dw    0x03                ; x86 machine
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

          mov eax, 4                ; write system call number
          mov ebx, 1                ; stdout
          mov ecx, msg              ; the message pointer
          mov edx, msglen           ; the message length
          int 0x80                  ; perform the write
          mov eax, 1                ; exit system call number
          mov ebx, 0                ; error code 0 (success)
          int 0x80                  ; perform the exit

; data
msg:        db    "Hello, World",10
msglen      equ   $ - msg

codesegsize equ   $ - _start 
filesize    equ   $ - $$

