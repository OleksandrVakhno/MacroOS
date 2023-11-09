org 0x7C00 ; directive that tell assembler where to expect our code to be loaded. The assembler uses this information to calculate label addresses
bits 16 ; directive that tell assembler to generate 16-bit code

main:
    hlt ; halt the CPU

.hlt:
    jmp .hlt ; jump to .hlt label for infinite loop

; DB byte1, byte2, byte3 (directive) - define bytes - writes bytes to the assembled binary 
; Times (directive) - repeat the following instruction a number of times
; $ - special symbol which is equal to the memmory offset of the current line
; $$ - special symbol which is equal to the memmory offset of the current section
; $-$$ - (current line offset) - (current section offset) = size of our program so far
times 510- ($-$$) db 0 ; fill the rest of the sector with zeros

; DW word1, word2, word3 (directive) - define words - writes words (2 byte value, encoded in little endian) to the assembled binary
dw 0xAA55 ; write the boot signature at the end of the sector
