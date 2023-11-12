org 0x7C00 ; directive that tell assembler where to expect our code to be loaded. The assembler uses this information to calculate label addresses
bits 16 ; directive that tell assembler to generate 16-bit code

; define a macro - a sequence of instructions that is given a name and can be used anywhere in the program
%define ENDL 0x0D, 0x0A ; define a macro ENDL that expands to 0x0D, 0x0A

; 
; FAT12 header: ntfs.com/fat-partition-sector.htm
; 
jmp short start ; jump to start label
nop ; no operation - used to pad the sector to 3 bytes

bdb_oem:                    db "MSWIN4.1" ; OEM name - 8 bytes
bdb_bytes_per_sector:       dw 512 ; bytes per sector
bdb_sectors_per_cluster:    db 1 ; sectors per cluster
bdb_reserved_sectors_count: dw 1 ; number of reserved sectors
bdb_fat_count:              db 2 ; number of FATs 
bdb_dir_entries_count:      dw 0E0h ; number of directory entries 
bdb_total_sectors:          dw 2880 ; number of sectors * bytes pre sector = disk size => 2880 * 512 = 1.44 MB
bdb_media_descriptor:       db 0F0h ; media descriptor - F0h for 3.5" 1.44 MB floppy
bdb_sectors_per_fat:        dw 9 ; sectors per FAT :  Number of sectors occupied by each of the file allocation tables on the volume. 
bdb_sectors_per_track:      dw 18 ; sectors per track: The apparent disk geometry in use when the disk was low-level formatted.
bdb_heads:                  dw 2 ; number of heads: The apparent disk geometry in use when the disk was low-level formatted.
bdb_hidden_sectors:         dd 0 ; number of hidden sectors: The number of sectors preceding the partition that contains this FAT volume. This field should always be zero on media that are not partitioned. This DOS 3.0 entry is incompatible with OS/2 and Windows NT.
bdb_large_sector_count:     dd 0 ; total sectors: This field is set to zero for FAT12 and FAT16 volumes and holds the total number of sectors on the volume for FAT32 volumes. This count includes the count of hidden sectors in the bdb_hidden_sectors field.

; extended boot record
ebr_drive_number:           db 0 ; drive number: This field is the zero-based number of the hard disk that this volume resides on. Floppy disk drives are numbered starting with 0x00 and hard disk drives are numbered starting with 0x80, regardless of how many physical disk drives are present.
                            db 0 ; reserved
ebr_signature:              db 29h ; extended boot signature: This field is a signature byte used to validate the EBR. The value of this field is 0x29 if the three following fields in the EBR are valid. Otherwise the value is some random value and the EBR is not considered to be present.
ebr_volume_id:              dd 12h, 34h, 56h, 78h ; volume ID: This is a random serial number that is created when a volume is formatted. Windows NT uses this number to identify each FAT volume globally (across all disks) in a network environment.
ebr_volume_label:           db "MacroOS    " ; volume label: This is a field of 11 characters used to identify the volume. This field matches the volume label stored in the root directory entry for the volume. This field is padded with spaces. The volume label is case insensitive and is typically displayed by the DIR command.
ebr_system_id:              db "FAT12   " ; system ID: This is a field of 8 characters used to describe the operating system that formatted the volume. This field is padded with spaces. The system ID is case insensitive and is typically displayed by the DIR command.


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
