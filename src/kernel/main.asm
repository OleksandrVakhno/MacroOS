org 0x7C00 ; directive that tell assembler where to expect our code to be loaded. The assembler uses this information to calculate label addresses
bits 16 ; directive that tell assembler to generate 16-bit code

; define a macro - a sequence of instructions that is given a name and can be used anywhere in the program
%define ENDL 0x0D, 0x0A ; define a macro ENDL that expands to 0x0D, 0x0A

start:
    jmp main ; jump to main label

; 
; Prints a string to the screen
; Params:
;   ds:si - pointer to the string to print
;
puts:
    ; push registers to the stack
    push si
    push ax

.loop:
    ; load the byte from ds:si into al
    lodsb

    ; if al is 0, we reached the end of the string
    or al, al ; OR al, al - sets the zero flag if al is 0
    jz .done ; jump to .done label if zero flag is set

    ; print the character in al
    mov ah, 0x0E ; set ah to 0x0E - teletype output
    mov bh, 0x00 ; set bh to 0x00 - page number 
    int 0x10 ; call interrupt 0x10 - video services - prints the character in al
    jmp .loop

.done:
    ; restore registers from the stack
    pop ax
    pop si

    ret

main:

    ; MOV destination, source - move data from source to destination
    ; setup data segments
    mov ax, 0 ; can't write to ds/es directly
    mov ds, ax ; set ds to 0
    mov es, ax ; set es to 0

    ; setup stack segment
    mov ss, ax ; set stack segment to 0
    mov sp, 0x7C00 ; set stack pointer to 0x7C00- the beginning of our program - stack grows downwards from where we are loaded program e.g. from 0x7C00 to 0x7BFF - this allows not to override our program

    ; print a message
    mov si, msg_hello ; set si to point to msg_hello
    call puts ; call puts with ds:si as the parameter


    hlt ; halt the CPU

.hlt:
    jmp .hlt ; jump to .hlt label for infinite loop

; define a label - a name for a memory address
msg_hello: db 'Hello world!', ENDL, 0 ; define a string - a sequence of characters terminated by 0, db - define bytes - writes bytes to the assembled binary

; DB byte1, byte2, byte3 (directive) - define bytes - writes bytes to the assembled binary 
; Times (directive) - repeat the following instruction a number of times
; $ - special symbol which is equal to the memmory offset of the current line
; $$ - special symbol which is equal to the memmory offset of the current section
; $-$$ - (current line offset) - (current section offset) = size of our program so far
times 510- ($-$$) db 0 ; fill the rest of the sector with zeros

; DW word1, word2, word3 (directive) - define words - writes words (2 byte value, encoded in little endian) to the assembled binary
dw 0xAA55 ; write the boot signature at the end of the sector
