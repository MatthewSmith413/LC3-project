; https://wchargin.com/lc3web

.ORIG x0000 ; Starting place in memory for our code

TRAP x01 ; jump to the OS
.FILL x0200 ; where the OS starts
.FILL x3000 ; where the user code starts
.BLKW x1d
.FILL x0400 ; GETC 
.FILL x0430 ; OUT
.FILL x0450 ; PUTS
.FILL x04a0 ; IN
.FILL x04e0 ; PUTSP
.FILL xfd70 ; HALT
.BLKW x1da

OS_START

LS
LEA r0, DIRECTORY
OUTS
TRAP x1

MK
LD r1, DIRECTORY_PTR
LEA r0, DIRECTORY
ADD r1, r0, r1
DIRECTORY_PTR .FILL x0
DIRECTORY .blkw x80


.END
