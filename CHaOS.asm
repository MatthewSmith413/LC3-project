; Custom Halfassed Operating System (CHaOS)
.ORIG x0000

; custom traps start at 3
; 0 is used to jump to the start of the operating system
HALT ;jump straight into the os
.FILL x3000 ;main code address
.BLKW x1E ;other code address
;keyword traps
.FILL TRAP_GETC ; x20 GETC
.FILL TRAP_OUT ; x21 OUT
.FILL TRAP_PUTS ; x22 PUTS
.FILL TRAP_IN ; x23 IN
.FILL TRAP_PUTSP ; x24 PUTSP
.FILL OS_START ; x25 HALT
;custom traps
.FILL TRAP_ALLOCATE ; x26
.FILL TRAP_GETK ; x27
.FILL TRAP_WRAPSHIFT ; x28
.FILL TRAP_OUTH ; x29
.FILL TRAP_STR ; x2A
.FILL TRAP_ADDC ; x2B
.FILL TRAP_MULT ; x2C
.FILL TRAP_COLOR ; x2D
.FILL TRAP_SPOT ; x2E
.FILL TRAP_POINT ; x2F
.FILL TRAP_RECT ; x30
.FILL TRAP_DEALLOCATE ; x31
.FILL TRAP_RAND ; x32
.FILL TRAP_DIV ; x33
.FILL TRAP_SIN ; x34
.FILL TRAP_COS ; x35
.FILL TRAP_CARTESIAN ; x36
.FILL TRAP_SORT ; x37
.FILL TRAP_UDIV_CARRY ; x38
.BLKW x1C7

; pc x200
OS_START
LD r0, ALLOCATION_START ; r0 = table[0] address
LDI r1, ALLOCATION_POINTER_PTR
NOT r2, r1
ADD r2, r2, #1 ; -table end pos
AND r1, r1, #0 ; 0
CLEAR_ALLOCATION_TABLE_LOOP ; do{
STR r1,r0,#0 ; table[r0] = #0
ADD r0,r0,#1 ; r0++
ADD r3,r2,r0 ; }while( index-table end pos <= 0 )
BRnz CLEAR_ALLOCATION_TABLE_LOOP
LD r1, ALLOCATION_START ; reset allocation pointer to start
STI r1, ALLOCATION_POINTER_PTR
AND r0, r0, #0 ; reset all registers
AND r1, r1, #0
AND r2, r2, #0
AND r3, r3, #0
AND r4, r4, #0
AND r5, r5, #0
AND r6, r6, #0
AND r7, r7, #0
TRAP x1 ;break to user code
ALLOCATION_START .FILL x4000
ALLOCATION_POINTER_PTR .FILL ALLOCATION_POINTER

KBSR .FILL xFE00
KBDR .FILL xFE02
TRAP_GETC ;;; wait for user to press key then load it to r0
LDI r0, KBSR
BRz TRAP_GETC
LDI r0, KBDR
RET
TRAP_GETK ;;; load last pressed key to r0
LDI r0, KBDR
RET

DSR .FILL xFE04
DDR .FILL xFE06
TRAP_OUT ;;; write character specified by r0 to console
ST r1, TRAP_OUT_SAVE_1 ; save r1
TRAP_OUT_LOOP LDI r1, DSR
BRz TRAP_OUT
STI r0, DDR
LD r1, TRAP_OUT_SAVE_1 ; restore r1
RET
TRAP_OUT_SAVE_1 .BLKW 1

TRAP_PUTS ;;; write a null terminated string to console that starts at the address specified by R0
ST r0, TRAP_PUTS_SAVE_0 ; save r0, r1 and r7
ST r1, TRAP_PUTS_SAVE_1
ST r7, TRAP_PUTS_SAVE_7
ADD r1, r0, #0 ; r1 points to char
PUTS_LOOP ; while(true){
LDR r0, r1, #0 ; r0=string[r1]
BRz PUTS_DONE ; if(char == 0) break;
OUT ; print r0
ADD r1, r1, #1 ; r1++
BRnzp PUTS_LOOP ; }
PUTS_DONE
LD r0, TRAP_PUTS_SAVE_0 ; restore r0, r1, and r7
LD r1, TRAP_PUTS_SAVE_1
LD r7, TRAP_PUTS_SAVE_7
RET
TRAP_PUTS_SAVE_0 .BLKW 1
TRAP_PUTS_SAVE_1 .BLKW 1
TRAP_PUTS_SAVE_7 .BLKW 1

PACK_MASK .FILL xff
TRAP_PUTSP ;;; write a string (null terminated, packed two chars per word, low byte then high byte) to the console starting at the address specified by r0
ST r0, TRAP_PUTSP_SAVE_0 ; save r0, r1, r2, and r7
ST r1, TRAP_PUTSP_SAVE_1
ST r2, TRAP_PUTSP_SAVE_2
ST r7, TRAP_PUTSP_SAVE_7
ADD r1, r0, #0 ; r1 = string[0]*
LD r2, PACK_MASK ; r2 = xff
PUTSP_LOOP ; while(true){
LDR r0, r1, #0 ; r0 = string[r1] & xff
AND r0, r0, r2
BRz PUTSP_DONE ; if(char == 0) break
OUT ; print r0
LDR r0, r1, #0 ; r0 = string[r1] >> 8
TRAP x28
TRAP x28
TRAP x28
TRAP x28
TRAP x28
TRAP x28
TRAP x28
TRAP x28
AND r0, r0, r2
BRz PUTSP_DONE ; if(char == 0) break
OUT ; print r0
ADD r1, r1, #1 ; r1++
BRnzp PUTSP_LOOP ; }
PUTSP_DONE
LD r0, TRAP_PUTSP_SAVE_0 ; restore r0, r1, r2, and r7
LD r1, TRAP_PUTSP_SAVE_1
LD r2, TRAP_PUTSP_SAVE_2
LD r7, TRAP_PUTSP_SAVE_7
RET
TRAP_PUTSP_SAVE_0 .BLKW 1
TRAP_PUTSP_SAVE_1 .BLKW 1
TRAP_PUTSP_SAVE_2 .BLKW 1
TRAP_PUTSP_SAVE_7 .BLKW 1

IN_STRING
.fill x6f53
.fill x656d
.fill x6620
.fill x6375
.fill x656b
.fill x2072
.fill x6564
.fill x6963
.fill x6564
.fill x2064
.fill x6874
.fill x7461
.fill x7420
.fill x6568
.fill x6320
.fill x646f
.fill x7265
.fill x6e20
.fill x6565
.fill x6564
.fill x2064
.fill x2061
.fill x7270
.fill x7765
.fill x6972
.fill x7474
.fill x6e65
.fill x7020
.fill x6f72
.fill x706d
.fill x2074
.fill x6f74
.fill x6120
.fill x6b73
.fill x7420
.fill x6568
.fill x7520
.fill x6573
.fill x2072
.fill x6f66
.fill x2072
.fill x2061
.fill x6863
.fill x7261
.fill x6361
.fill x6574
.fill x2c72
.fill x7420
.fill x6568
.fill x206e
.fill x6874
.fill x2065
.fill x6f63
.fill x6564
.fill x2072
.fill x6564
.fill x6963
.fill x6564
.fill x2064
.fill x6f74
.fill x7520
.fill x6573
.fill x6920
.fill x2e74
.fill x4f20
.fill x206e
.fill x6e61
.fill x7520
.fill x726e
.fill x6c65
.fill x7461
.fill x6465
.fill x6e20
.fill x746f
.fill x2c65
.fill x6820
.fill x7275
.fill x7972
.fill x7520
.fill x2070
.fill x6e61
.fill x2064
.fill x7270
.fill x7365
.fill x2073
.fill x2061
.fill x7566
.fill x6b63
.fill x6e69
.fill x2067
.fill x656b
.fill x2e79
.fill x4920
.fill x6d27
.fill x7720
.fill x6961
.fill x6974
.fill x676e
.fill x002e
TRAP_IN ;;; Prompt user with a predetermined string, then return the character typed in r0. This is the single most useless trap in existence but I have nothing else to put here without disobeying documentation
ST r7, TRAP_IN_SAVE_7 ; save r7
LEA r0, IN_STRING
PUTSP
GETC
LD r7, TRAP_IN_SAVE_7 ; restore r7
RET
TRAP_IN_SAVE_7 .BLKW 1

ALLOCATION_POINTER .BLKW 1
TRAP_ALLOCATE ;;; make a vector pointing to the next available spot in memory after allocating the amount specified by r0, then load the address of the last pointer to r0 and return.
ST r1, TRAP_ALLOCATE_SAVE_1 ; save r1 and r2
ST r2, TRAP_ALLOCATE_SAVE_2
LD r1, ALLOCATION_POINTER ; r1 = current address
ADD r2, r0, r1 ; r2 = next address
ADD r0, r1, #0 ; r0 = current address
ST r2, ALLOCATION_POINTER ; update next address
LD r1, TRAP_ALLOCATE_SAVE_1 ; restore r1 and r2
LD r2, TRAP_ALLOCATE_SAVE_2
RET
TRAP_ALLOCATE_SAVE_1 .BLKW 1
TRAP_ALLOCATE_SAVE_2 .BLKW 1

TRAP_WRAPSHIFT ;;; r0 << 1 + (MSB >> F)
ADD r0, r0, #0
BRn POSITIVE_SHIFT
ADD r0, r0, r0
RET
POSITIVE_SHIFT
ADD r0, r0, r0
ADD r0, r0, #1
RET

TRAP_OUTH ;;; Print the raw hex code in r0
ST r1, TRAP_OUTH_SAVE_1 ; save r1, r2, r3, r4, r5, and r7
ST r2, TRAP_OUTH_SAVE_2
ST r3, TRAP_OUTH_SAVE_3
ST r4, TRAP_OUTH_SAVE_4
ST r5, TRAP_OUTH_SAVE_5
ST r7, TRAP_OUTH_SAVE_7
LD r2, ASCII_0 ; r2 = ‘0’
LD r3, NOT_ASCII_9 ; r3 = !’9’
AND r5, r5, #0 ; r5 = 4
ADD r5, r5, #4
OUTH_SHIFTPRINT_LOOP ; do{
TRAP x28 ; r0 = r0 >> xc + r0 << 4
TRAP x28
TRAP x28
TRAP x28
AND r1, r0, xf ; r1 = r0 & xf
ADD r1, r1, r2 ; r1 → ‘0’
ADD r4, r3, r1 ; if(r1 > ‘9’) {
BRn OUTH_SKIP
ADD r1, r1, #7 ; r1 → ‘A’
OUTH_SKIP ; }
ADD r4, r0, #0 ; r4=r0
ADD r0, r1, #0 ; r0=r1
OUT ; print r0
ADD r0, r4, #0 ; r0=r4
ADD r5, r5, #-1 ; r5–
BRP OUTH_SHIFTPRINT_LOOP ; }while(r5>0)
LD r1, TRAP_OUTH_SAVE_1 ; restore r1, r2, r3, r4, r5, and r7
LD r2, TRAP_OUTH_SAVE_2
LD r3, TRAP_OUTH_SAVE_3
LD r4, TRAP_OUTH_SAVE_4
LD r5, TRAP_OUTH_SAVE_5
LD r7, TRAP_OUTH_SAVE_7
RET
TRAP_OUTH_SAVE_1 .BLKW 1
TRAP_OUTH_SAVE_2 .BLKW 1
TRAP_OUTH_SAVE_3 .BLKW 1
TRAP_OUTH_SAVE_4 .BLKW 1
TRAP_OUTH_SAVE_5 .BLKW 1
TRAP_OUTH_SAVE_7 .BLKW 1
ASCII_0 .FILL x0030
NOT_ASCII_9 .fill xFFC6

TRAP_STR ;;; Convert r0 to a hex string spread out across r0-r3, with r0 as the low nybble
ST r4, TRAP_STR_SAVE_4 ; save r4 and r7
ST r7, TRAP_STR_SAVE_7
LD r4, ASCII_0_MOVED_9 ; r4 = ‘0’
TRAP x28 ; r0 = r0 << 4 + r0 >> xc
TRAP x28
TRAP x28
TRAP x28
AND r3, r0, xf ; r3 = low nybble of r0
ADD r3, r3, #-9 ; if(r3 > 9){
BRnz TRAP_STR_SKIP_0
ADD r3, r3, #7 ; r3+=7
TRAP_STR_SKIP_0 ; }
ADD r3, r3, r4 ; r3 → ‘0’
TRAP x28 ; r0 = r0 << 4 + r0 >> xc
TRAP x28
TRAP x28
TRAP x28
AND r2, r0, xf ; r2 = low nybble of r0
ADD r2, r2, #-9 ; if(r2 > 9){
BRnz TRAP_STR_SKIP_1
ADD r2, r2, #7 ; r2+=7
TRAP_STR_SKIP_1 ; }
ADD r2, r2, r4 ; r2 → ‘0’
TRAP x28 ; r0 = r0 << 4 + r0 >> xc
TRAP x28
TRAP x28
TRAP x28
AND r1, r0, xf ; r1 = low nybble of r0
ADD r1, r1, #-9 ; if(r1 > 9){
BRnz TRAP_STR_SKIP_2
ADD r1, r1, #7 ; r1+=7
TRAP_STR_SKIP_2 ; }
ADD r1, r1, r4 ; r1 → ‘0’
TRAP x28 ; r0 = r0 << 4 + r0 >> xc
TRAP x28
TRAP x28
TRAP x28
AND r0, r0, xf ; r0 = low nybble of r0
ADD r0, r0, #-9 ; if(r0 > 9){
BRnz TRAP_STR_SKIP_3
ADD r0, r0, #7 ; r0+=7
TRAP_STR_SKIP_3 ; }
ADD r0, r0, r4 ; r0 → ‘0’
LD r4, TRAP_STR_SAVE_4 ; restore r4 and r7
LD r7, TRAP_STR_SAVE_7
RET
TRAP_STR_SAVE_4 .BLKW 1
TRAP_STR_SAVE_7 .BLKW 1
ASCII_0_MOVED_9 .FILL x0039

TRAP_ADDC ;;; r1 = r1+r0, r0 gets carry bit
ST r2, TRAP_ADDC_SAVE_2 ; save r2 and r3
ST r3, TRAP_ADDC_SAVE_3
AND r2, r2, #0 ; r2 = 0
ADD r3, r2, #3 ; r3 = 3
ADD r0, r0, #0 ; first iteration
BRzp ADDC_SKIP_0
ADD r2, r2, #1
ADDC_SKIP_0
ADD r1, r1, #0 ; second iteration, can’t be removed
BRzp ADDC_SKIP_1
ADD r2, r2, #1
ADDC_SKIP_1
ADD r1, r1, r0 ; r1 = r1+r0
BRzp ADDC_SKIP_2 ; what the fuck?
ADD r3, r3, #-1
ADDC_SKIP_2
AND r0, r0, #0 ; r0 = 0
AND r2, r2, r3 ; evil karnaugh map bit hack
BRz ADDC_SKIP_3
ADD r0, r0, #1
ADDC_SKIP_3
LD r2, TRAP_ADDC_SAVE_2 ; restore r2 and r3
LD r3, TRAP_ADDC_SAVE_3
RET
TRAP_ADDC_SAVE_2 .BLKW 1
TRAP_ADDC_SAVE_3 .BLKW 1

TRAP_MULT ;;; multiply r0 and r1, upper half in r0 and lower half in r1.
ST r2, TRAP_MULT_SAVE_2 ; SAVE FUCKING EVERYTHING
ST r3, TRAP_MULT_SAVE_3
ST r4, TRAP_MULT_SAVE_4
ST r5, TRAP_MULT_SAVE_5
ST r6, TRAP_MULT_SAVE_6
ST r7, TRAP_MULT_SAVE_7
AND r4, r4, #0 ; track the sign of A*B
ADD r2, r0, #0 ; r2 = |A|
BRzp TRAP_MULT_SKIP_0
ADD r4, r4, #1
NOT r2, r2
ADD r2, r2, #1
TRAP_MULT_SKIP_0
ADD r3, r1, #0 ; r3 = |B|
BRzp TRAP_MULT_SKIP_1
ADD r4, r4, #1
NOT r3, r3
ADD r3, r3, #1
TRAP_MULT_SKIP_1
AND r4, r4, #1 ; store sign of A*B
ST r4, TRAP_MULT_SIGN_BIT
AND r4, r4, #0 ; {r4, r1} = 0, low_mask = xffff, r6 = 1
AND r1, r1, #0
NOT r5, r1
ADD r6, r1, #1
TRAP_MULT_LOOP; do {
AND r7, r2, r6 ; if(|A| & r6){
BRz TRAP_MULT_SKIP_2
AND r0, r3, r5 ; {r4, r1} += {|B| & !low_mask, |B| & low_mask}
TRAP x2b
ADD r4, r4, r0
NOT r5, r5
AND r0, r3, r5
ADD r4, r4, r0
NOT r5, r5
TRAP_MULT_SKIP_2 ; }
ADD r0, r3, #0 ; B = B << 1 + B >> xf
TRAP x28
ADD r3, r0, #0
ADD r5, r5, r5 ; low_mask <<= 1
ADD r6, r6, r6 ; r6 <<= 1
BRp TRAP_MULT_LOOP ; }while(r6 > 0)
LD r0, TRAP_MULT_SIGN_BIT ; if( sign bit ){
BRz TRAP_MULT_SKIP_3
NOT r1, r1 ; {r4, r1} = -{r4, r1}
NOT r4, r4
TRAP x2b
ADD r4, r4, r0
TRAP_MULT_SKIP_3 ; }
ADD r0, r4, #0 ; {r0, r1} = {r4, r1}
; PUT THOSE THINGS BACK WHERE THEY CAME FROM OR SO HELP ME
LD r2, TRAP_MULT_SAVE_2
LD r3, TRAP_MULT_SAVE_3
LD r4, TRAP_MULT_SAVE_4
LD r5, TRAP_MULT_SAVE_5
LD r6, TRAP_MULT_SAVE_6
LD r7, TRAP_MULT_SAVE_7
RET
TRAP_MULT_SAVE_2 .BLKW 1
TRAP_MULT_SAVE_3 .BLKW 1
TRAP_MULT_SAVE_4 .BLKW 1
TRAP_MULT_SAVE_5 .BLKW 1
TRAP_MULT_SAVE_6 .BLKW 1
TRAP_MULT_SAVE_7 .BLKW 1
TRAP_MULT_SIGN_BIT .BLKW 1

TRAP_COLOR ;;; takes r0=r, r1=g, r2=b, and returns r3=result
ST r0, TRAP_COLOR_SAVE_0 ; save r0 and r1
ST r1, TRAP_COLOR_SAVE_1
LD r3, TRAP_COLOR_MASK ; mask the colors to low 5 bits
AND r0, r0, r3
AND r1, r1, r3
AND r2, r2, r3
ADD r3, r2, #0 ; r3 = r2
ADD r1, r1, r1 ; r1 <<= 5
ADD r1, r1, r1
ADD r1, r1, r1
ADD r1, r1, r1
ADD r1, r1, r1
ADD r3, r3, r1 ; r3 += r1
ADD r0, r0, r0 ; r0 <<= xa
ADD r0, r0, r0
ADD r0, r0, r0
ADD r0, r0, r0
ADD r0, r0, r0
ADD r0, r0, r0
ADD r0, r0, r0
ADD r0, r0, r0
ADD r0, r0, r0
ADD r0, r0, r0
ADD r3, r3, r0 ; r3 += r0
LD r0, TRAP_COLOR_SAVE_0 ; restore r0 and r1
LD r1, TRAP_COLOR_SAVE_1
RET
TRAP_COLOR_SAVE_0 .BLKW 1
TRAP_COLOR_SAVE_1 .BLKW 1
TRAP_COLOR_MASK .FILL x001F

TRAP_SPOT ;;; takes point (r0, r1) and sets r2 to the relevant address, or 0 if invalid. sets cc based on result.
ST r1, TRAP_SPOT_SAVE_1
ADD r0, r0, #0
BRn TRAP_SPOT_OOB
ADD r1, r1, #0
BRn TRAP_SPOT_OOB
LD r2, TRAP_SPOT_NEG_MAX_WIDTH
ADD r2, r0, r2
BRp TRAP_SPOT_OOB
LD r2, TRAP_SPOT_NEG_MAX_HEIGHT
ADD r2, r1, r2
BRp TRAP_SPOT_OOB
ADD r1, r1, r1
ADD r1, r1, r1
ADD r1, r1, r1
ADD r1, r1, r1
ADD r1, r1, r1
ADD r1, r1, r1
ADD r1, r1, r1
LD r2, TRAP_SPOT_SCREEN_START
ADD r2, r2, r0
ADD r2, r2, r1
LD r1, TRAP_SPOT_SAVE_1
ADD r2, r2, #0
RET
TRAP_SPOT_OOB
AND r2, r2, #0
RET
TRAP_SPOT_SAVE_1 .BLKW 1
TRAP_SPOT_NEG_MAX_WIDTH .FILL xFF81
TRAP_SPOT_NEG_MAX_HEIGHT .FILL xFF85
TRAP_SPOT_SCREEN_START .FILL xC000

TRAP_POINT ;;; draws a point at (r0, r1) with the color r2.
ST r3, TRAP_POINT_SAVE_3 ; save r3 and r7
ST r7, TRAP_POINT_SAVE_7
ADD r3, r2, #0 ; find spot
TRAP x2e
BRz TRAP_POINT_OOB ; if(point is on screen)
STR r3, r2, #0 ; draw point
ADD r2, r3, #0
TRAP_POINT_OOB
LD r3, TRAP_POINT_SAVE_3 ; restore r3 and r7
LD r7, TRAP_POINT_SAVE_7
RET
TRAP_POINT_SAVE_3 .BLKW 1
TRAP_POINT_SAVE_7 .BLKW 1

TRAP_RECT ;;; r0, r1, r2, r3, r4 = x, y, w, h, color
ST r0, TRAP_RECT_SAVE_0
ST r1, TRAP_RECT_SAVE_1
ST r2, TRAP_RECT_SAVE_2
ST r3, TRAP_RECT_SAVE_3
ST r5, TRAP_RECT_SAVE_5
ST r6, TRAP_RECT_SAVE_6
ST r7, TRAP_RECT_SAVE_7
ADD r2, r2, #0 ;if(width == 0)
BRz TRAP_RECT_DONE ; dont draw
BRp TRAP_RECT_SKIP_0 ; if(width < 0) {
ADD r0, r0, r2 ; flip rectangle horizontally
NOT r2, r2
ADD r2, r2, #1
TRAP_RECT_SKIP_0
ADD r3, r3, #0 ; if(height == 0)
BRz TRAP_RECT_DONE ; dont draw
BRp TRAP_RECT_SKIP_1 ; if(height < 0) {
ADD r1, r1, r3 ; flip rectangle vertically
NOT r3, r3
ADD r3, r3, #1
TRAP_RECT_SKIP_1 ; }
ADD r2, r2, #-1; dont question it
ADD r3, r3, #-1
ADD r7, r0, r2 ; if the entire rectangle is left of the screen
BRn TRAP_RECT_DONE ; dont draw
ADD r7, r1, r3 ; if the entire rectangle is above the screen
BRn TRAP_RECT_DONE ; dont draw
LD r7, TRAP_RECT_NEG_MAX_WIDTH ; if the entire rectangle is right of the screen
ADD r7, r7, r0
BRp TRAP_RECT_DONE ; dont draw
LD r7, TRAP_RECT_NEG_MAX_HEIGHT ; if the entire rectangle is below the screen
ADD r7, r7, r1
BRp TRAP_RECT_DONE ; dont draw
ADD r0, r0, #0 ; if(it goes over the left){
BRzp TRAP_RECT_SKIP_2
ADD r2, r2, r0 ; shrink it right
AND r0, r0, #0
TRAP_RECT_SKIP_2 ; }
ADD r1, r1, #0 ; if(it goes over the top){
BRzp TRAP_RECT_SKIP_3
ADD r3, r3, r1 ; shrink it down
AND r1, r1, #0
TRAP_RECT_SKIP_3 ; }
LD r7, TRAP_RECT_NEG_MAX_WIDTH ; if(it goes over the right){
ADD r7, r7, r0
ADD r7, r7, r2
BRnz TRAP_RECT_SKIP_4
NOT r7, r7 ; shrink it left
ADD r7, r7, #1
ADD r2, r2, r7
TRAP_RECT_SKIP_4 ; }
LD r7, TRAP_RECT_NEG_MAX_HEIGHT ; if(it goes over the top){
ADD r7, r7, r1
ADD r7, r7, r3
BRnz TRAP_RECT_SKIP_5
NOT r7, r7 ; shrink it left
ADD r7, r7, #1
ADD r3, r3, r7
TRAP_RECT_SKIP_5 ;}
ADD r5, r2, #0
TRAP x2e
ADD r6, r2, #0
; r6 is pointer
ADD r0, r0, r5
ADD r1, r1, r3
TRAP x2e
NOT r2, r2
ADD r2, r2, #1
; r2 = -endpoint
LD r7, TRAP_RECT_SCREEN_WIDTH
NOT r5, r5 ; r7 = width-w
ADD r7, r7, r5
ADD r7, r7, #1
NOT r5, r5
ADD r0, r5, #0 ; r0 is width counter
TRAP_RECT_LOOP ; do{
STR r4, r6, #0 ; draw point
ADD r6, r6, #1 ; move point to the right
ADD r0, r0, #-1 ; decrement width counter
BRp TRAP_RECT_SKIP_N ; if width counter <= 0
ADD r0, r5, #0 ; reset width counter
ADD r6, r6, r7 ; go to start of next row
TRAP_RECT_SKIP_N
ADD r1, r6, r2
BRnz TRAP_RECT_LOOP ; }while(pointer <= endpoint)
TRAP_RECT_DONE
LD r0, TRAP_RECT_SAVE_0
LD r1, TRAP_RECT_SAVE_1
LD r2, TRAP_RECT_SAVE_2
LD r3, TRAP_RECT_SAVE_3
LD r5, TRAP_RECT_SAVE_5
LD r6, TRAP_RECT_SAVE_6
LD r7, TRAP_RECT_SAVE_7
RET
TRAP_RECT_SAVE_0 .BLKW 1
TRAP_RECT_SAVE_1 .BLKW 1
TRAP_RECT_SAVE_2 .BLKW 1
TRAP_RECT_SAVE_3 .BLKW 1
TRAP_RECT_SAVE_5 .BLKW 1
TRAP_RECT_SAVE_6 .BLKW 1
TRAP_RECT_SAVE_7 .BLKW 1
TRAP_RECT_SCREEN_WIDTH .FILL x0080
TRAP_RECT_NEG_MAX_WIDTH .FILL xFF81
TRAP_RECT_NEG_MAX_HEIGHT .FILL xFF85

TRAP_DEALLOCATE ;;; deallocates the amount of memory specified by r0 and clears it, then loads the next available address to r0 and returns
ST r1, TRAP_DEALLOCATE_SAVE_1 ; save r1, r2, r3, and r4
ST r2, TRAP_DEALLOCATE_SAVE_2
ST r3, TRAP_DEALLOCATE_SAVE_3
ST r4, TRAP_DEALLOCATE_SAVE_4
LDI r1, TRAP_DEALLOCATE_PTR ; r1 = current abailable address
NOT r2, r0 ; r2 = next available address
ADD r2, r2, #1
ADD r2, r2, r1
STI r2, TRAP_DEALLOCATE_PTR ; current abailable address = next available address
AND r3, r3, #0 ; r3 = 0
NOT r2, r2 ; r2 *=-1
ADD r2, r2, #1
TRAP_DEALLOCATE_LOOP ; do{
ADD r1, r1, #-1; r1–
STR r3, r1, #0 ; mem[r1] = 0
ADD r4, r2, r1 ; }while(r1 != r2)
BRnp TRAP_DEALLOCATE_LOOP
ADD r0, r1, #0 ; r0 = next available address
LD r1, TRAP_DEALLOCATE_SAVE_1 ; restore r1, r2, r3, and r4
LD r2, TRAP_DEALLOCATE_SAVE_2
LD r3, TRAP_DEALLOCATE_SAVE_3
LD r4, TRAP_DEALLOCATE_SAVE_4
RET
TRAP_DEALLOCATE_PTR .FILL ALLOCATION_POINTER
TRAP_DEALLOCATE_SAVE_1 .BLKW 1
TRAP_DEALLOCATE_SAVE_2 .BLKW 1
TRAP_DEALLOCATE_SAVE_3 .BLKW 1
TRAP_DEALLOCATE_SAVE_4 .BLKW 1

TRAP_RAND ;;; puts a psuedorandom number in r0
ST r1, TRAP_RAND_SAVE_1
LD r0, TRAP_RAND_A
LD r1, TRAP_RAND_B
ADD r0, r0, r1
BRN TRAP_RAND_SKIP
ADD r0, r0, #1
TRAP_RAND_SKIP
ST r1, TRAP_RAND_A
LD r1, TRAP_RAND_SAVE_1
ST r0, TRAP_RAND_B
RET
TRAP_RAND_A .FILL x76AB
TRAP_RAND_B .FILL xF6A4
TRAP_RAND_SAVE_1 .BLKW 1

TRAP_DIV ;;; {r0, r1} = r0==0?{|r1|,sign(r1)}:{floor(r1/r0),r1%r0}
ST r2, TRAP_DIV_SAVE_2 ; save r1, r2, r3, r4, r5, r6
ST r3, TRAP_DIV_SAVE_3
ST r4, TRAP_DIV_SAVE_4
ST r5, TRAP_DIV_SAVE_5
ST r6, TRAP_DIV_SAVE_6
AND r5, r5, #0 ; r5 = sign(r1/r0), r0=|r0|, r1=|r1|
ADD r0, r0, #0
BRp TRAP_DIV_SKIP_0
BRn TRAP_DIV_0
NOT r0, r0
ADD r0, r0, #1
ADD r5, r5, #1
TRAP_DIV_SKIP_0
ADD r1, r1, #0
BRp TRAP_DIV_SKIP_1
NOT r1, r1
ADD r1, r1, #1
ADD r5, r5, #1
TRAP_DIV_SKIP_1
AND r5, r5, #1
NOT r2, r0 ; r2 = -r0, r0 = r3 = 0, r4 = 1
ADD r2, r2, #1
AND r0, r0, #0
AND r3, r3, #0
ADD r4, r0, #1
TRAP_DIV_LOOP ; do{
ADD r0, r0, r0 ; {r0, r1} <<=1
ADD r1, r1, #0
BRzp TRAP_DIV_SKIP_2
ADD r0, r0, #1
TRAP_DIV_SKIP_2
ADD r1, r1, r1
ADD r3, r3, r3 ; r3 <<=1
ADD r6, r0, r2 ; if(r0+r2 >= 0){
BRn TRAP_DIV_SKIP_3
ADD r0, r6, #0 ; r0+=r2
ADD r3, r3, #1 ; r3++
TRAP_DIV_SKIP_3 ; }
ADD r4, r4, r4 ; r4 <<=1
BRnp TRAP_DIV_LOOP ; }while(r4!==0)
ADD r5, r5, #0
BRz TRAP_DIV_SKIP_4
NOT r3, r3
ADD r3, r3, #1
TRAP_DIV_SKIP_4
ADD r1, r3, #0
BRnzp TRAP_DIV_NOT_0
TRAP_DIV_0
AND r0, r0, #0
AND r1, r1, #0
TRAP_DIV_NOT_0
LD r2, TRAP_DIV_SAVE_2
LD r3, TRAP_DIV_SAVE_3
LD r4, TRAP_DIV_SAVE_4
LD r5, TRAP_DIV_SAVE_5
LD r6, TRAP_DIV_SAVE_6
RET
TRAP_DIV_SAVE_2 .BLKW 1
TRAP_DIV_SAVE_3 .BLKW 1
TRAP_DIV_SAVE_4 .BLKW 1
TRAP_DIV_SAVE_5 .BLKW 1
TRAP_DIV_SAVE_6 .BLKW 1

TRAP_SIN ;;; r0=sin(r0)*x8000, x40 is a full turn
ST r1, TRAP_SIN_SAVE_1 ; save r1 and r2
ST r2, TRAP_SIN_SAVE_2
AND r1, r0, xf ; r1=r0&xf
LD r2, TRAP_SIN_MASK ; switch((r0>>4)&x3){
AND r0, r0, r2
BRz TRAP_SIN_CASE_0
ADD r0, r0, #-16
BRz TRAP_SIN_CASE_1
ADD r0, r0, #-16
BRz TRAP_SIN_CASE_2
ADD r0, r0, #-16
BRz TRAP_SIN_CASE_3
TRAP_SIN_CASE_0 ; quadrant1:
LEA r0, TRAP_SIN_TABLE ; r0 = sin_table[r1]
ADD r0, r0, r1
LDR r0, r0, #0
BRnzp TRAP_SIN_DONE ; break
TRAP_SIN_CASE_1 ; quadrant2:
LEA r0, TRAP_SIN_TABLE ; r0 = sin_table[x10-r1]
NOT r1, r1
ADD r0, r0, r1
LDR r0, r0, x11
BRnzp TRAP_SIN_DONE ; break
TRAP_SIN_CASE_2 ; quadrant3:
LEA r0, TRAP_SIN_TABLE ; r0 = -sin_table[r1]
ADD r0, r0, r1
LDR r0, r0, #0
NOT r0, r0
ADD r0, r0, #1
BRnzp TRAP_SIN_DONE ; break
TRAP_SIN_CASE_3 ; quadrant4:
LEA r0, TRAP_SIN_TABLE ; r0 = -sin_table[x10-r1]
NOT r1, r1
ADD r0, r0, r1
LDR r0, r0, x11
NOT r0, r0
ADD r0, r0, #1
TRAP_SIN_DONE ; }
LD r1, TRAP_SIN_SAVE_1 ; restore r1 and r2
LD r2, TRAP_SIN_SAVE_2
RET
TRAP_SIN_SAVE_1 .BLKW 1
TRAP_SIN_SAVE_2 .BLKW 1
TRAP_SIN_MASK .FILL x0030
TRAP_SIN_TABLE
.FILL x0000
.FILL x0C8C
.FILL x18F9
.FILL x2528
.FILL x30FB
.FILL x3C56
.FILL x471C
.FILL x5133
.FILL x5A82
.FILL x62F1
.FILL x6A6D
.FILL x70E2
.FILL x7641
.FILL x7A7C
.FILL x7D89
.FILL x7F61
.FILL x7FFF
.END

TRAP_COS ;;; r0 = x7fff*cos(r0)
ST r7, TRAP_COS_SAVE_7 ; save r7
ADD r0, r0, x8 ; rotate 45 degrees twice
ADD r0, r0, x8
TRAP x34 ; take the sin
LD r7, TRAP_COS_SAVE_7 ; restore r7
RET
TRAP_COS_SAVE_7 .BLKW 1

TRAP_CARTESIAN ;;; takes {r0,r1}={r,t} and returns {r0,r1}={x,y}. t=40 is 1 full turn, and r, x and y are from -x8000 to x7fff
ST r2, TRAP_CARTESIAN_SAVE_2
ST r7, TRAP_CARTESIAN_SAVE_7
ST r0, TRAP_CARTESIAN_R
ST r1, TRAP_CARTESIAN_THETA
LD r0, TRAP_CARTESIAN_THETA
TRAP x34 ; r0 = sin(theta)
LD r1, TRAP_CARTESIAN_R
TRAP x2c ; r0 = y
ADD r2, r0, #0
LD r0, TRAP_CARTESIAN_THETA
TRAP x35 ; r0 = cos(theta)
LD r1, TRAP_CARTESIAN_R
TRAP x2c ; r0 = x
ADD r1, r2, #0 ; r1 = y
LD r2, TRAP_CARTESIAN_SAVE_2
LD r7, TRAP_CARTESIAN_SAVE_7
RET
TRAP_CARTESIAN_SAVE_2 .BLKW 1
TRAP_CARTESIAN_SAVE_7 .BLKW 1
TRAP_CARTESIAN_R .BLKW 1
TRAP_CARTESIAN_THETA .BLKW 1

TRAP_SORT ;;; sorts r0 and r1 so r0 <= r1
ST r2, TRAP_SORT_SAVE_2 ; save r2
AND r2, r2 #0 ; if(sign(r0)!=sign(r1)){
ADD r0, r0, #0
BRzp TRAP_SORT_SKIP_0
ADD r2, r2, #1
TRAP_SORT_SKIP_0
ADD r1, r1, #0
BRzp TRAP_SORT_SKIP_1
ADD r2, r2, #1
TRAP_SORT_SKIP_1
AND r2, r2, #1
BRz TRAP_SORT_CASE_SAME
ADD r0, r0, #0 ; if(sign(r0)==1){
BRn TRAP_SORT_DONE
ADD r2, r0, #0 ; swap(r1, r2)
ADD r0, r1, #0
ADD r1, r2, #0
BRnzp TRAP_SORT_DONE ; return
TRAP_SORT_CASE_SAME ; }}else{
NOT r2, r1 ; if(r0-r1>0){
ADD r2, r2, #1
ADD r2, r2, r0
BRnz TRAP_SORT_DONE
ADD r2, r0, #0 ; swap(r1, r2)
ADD r0, r1, #0
ADD r1, r2, #0
TRAP_SORT_DONE ; }
LD r2, TRAP_SORT_SAVE_2 ; restore r2
RET
TRAP_SORT_SAVE_2 .BLKW 1

TRAP_UDIV_CARRY ;;; {r2, r1}/r0 → r2 is mod, r1 is quotient
ST r3, TRAP_UDIV_CARRY_3
ST r4, TRAP_UDIV_CARRY_4
ST r5, TRAP_UDIV_CARRY_5
NOT r0, r0
ADD r0, r0, #1
AND r3, r3, #0
AND r4, r4, #0
ADD r4, r4, #1
TRAP_UDIV_CARRY_LOOP
ADD r3, r3, r3
ADD r2, r2, r2
ADD r1, r1, #0
BRzp TRAP_UDIV_CARRY_SKIP_0
ADD r2, r2, #1
TRAP_UDIV_CARRY_SKIP_0
ADD r1, r1, r1
ADD r5, r2, r0
BRn TRAP_UDIV_CARRY_SKIP_1
ADD r2, r5, #0
ADD r3, r3, #1
TRAP_UDIV_CARRY_SKIP_1
ADD r4, r4, r4
BRnp TRAP_UDIV_CARRY_LOOP
ADD r1, r3, #0
NOT r0, r0
ADD r0, r0, #1
LD r3, TRAP_UDIV_CARRY_3
LD r4, TRAP_UDIV_CARRY_4
LD r5, TRAP_UDIV_CARRY_5
RET
TRAP_UDIV_CARRY_3 .BLKW 1
TRAP_UDIV_CARRY_4 .BLKW 1
TRAP_UDIV_CARRY_5 .BLKW 1

TRAP_MAP ;;; {r5, r6}=map(r0, r1, r2, r3, r4)
NOT r1, r1 ; adjust r0, r2, r4
ADD r1, r1, #1
ADD r0, r0, r1
ADD r2, r2, r1
NOT r1, r3
ADD r1, r1, #1
ADD r4, r4, r1
ADD r1, r4, #0 ; {r0, r1} = r0*r4
TRAP x2c
ADD r4, r1, #0 ; r4=r1, r1=r0, r0=r2, r2=0
ADD r1, r0, #0
ADD r0, r2, #0
AND r2, r2, #0
TRAP x38 ; {r6, r5} = {r6, r5}/r0
ADD r5, r1, #0
ADD r1, r4, #0
TRAP x38
ADD r6, r1, #0
RET
