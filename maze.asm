and r0, r0, #0
and r1, r1, #0
ld r2, screen
ld r3, screen
ld r4, cell_color
trap x30
ld r1, board_width ;; allocate space for board
ld r0, board_width
trap x2c
ld r0, cell_data_size
trap x2c
add r0, r1, #0
trap x26
st r0, cells
ld r3, board_width ;; load x and y location of each cell
not r3, r3
add r3, r3, #1
and r2, r2, #0
loop_y
	and r1, r1, #0
	loop_x
		str r1, r0, #0
		str r2, r0, #1
		add r0, r0, #7
		add r1, r1, #1
	add r4, r1, r3
	BRnp loop_x
	add r2, r2, #1
add r4, r2, r3
BRnp loop_y
;;; start allocation for stack
and r0, r0, #0
add r0, r0, #2
trap x26
add r2, r0, #2 ; r2 is cellptr
and r6, r6, #0 ; load stack with first point 0, 0
str r6, r0, #0
str r6, r0, #1
not r0, r0 ; save -stackstart
add r0, r0, #1
st r0, stackstart
loop ; do {
	;;; determine the cell surrounding options
	ldr r3, r2, #-2 ; r3=x, r4=y
	ldr r4, r2, #-1
	add r0, r4, #0 ; r1 = cells+(x+y*board_width)*cell_data_size
	ld r1, board_width ; aka r1 = *cells[x+y*board_width]
	trap x2c
	add r1, r1, r3
	ld r0, cell_data_size
	trap x2c
	ld r0, cells
	add r1, r1, r0
	and r0, r0, #0 ; cells[x+y*board_width][6] = 1
	add r0, r0, #1
	str r0, r1, #6
	jsr pushsurrounddata
	;;; if there are none, backtrack and continue
	add r6, r6, #0
	brnp skip_0
		and r0, r0, #0
		add r0, r0, #6
		trap x31
		add r2, r2, #-2
		brnzp continue
	skip_0
	;;; otherwise, randomly choose an available option
	trap x32 ; r1 = random % optioncounter + 1
	add r1, r0, #0
	add r0, r6, #0
	trap x33
	add r1, r0, #1
	and r0, r0, #0 ; r0 = -1
	add r0, r0, #-1
	find_loop ; do{
		add r0, r0, #1 ; r0++
		add r6, r2, r0 ; r1-=options[r0]
		ldr r6, r6, #0
		not r6, r6
		add r6, r6, #1
		add r1, r1, r6
	brnp find_loop ; }while(r1!=0)
	;;; fill current cell with connection data
	add r5, r0, #0 ; r5 is option
	and r0, r0, #0 ; deallocate top two values
	add r0, r0, #2
	trap x31
	add r2, r2, #2 ; update stack pointer to match
	add r1, r4, #0 ; cells[x, y][2+r5] = 1
	ld r0, board_width
	trap x2c
	add r1, r1, r3
	ld r0, cell_data_size
	trap x2c
	ld r0, cells
	add r1, r1, r0
	add r1, r1, r5
	and r0, r0, #0
	add r0, r0, #1
	str r0, r1, #2
	; switch (r5){ // r5 becomes 0
	add r5, r5, #0
	brz case_u
	add r5, r5, #-1
	brz case_d
	add r5, r5, #-1
	brz case_l
	add r5, r5, #-1
	brz case_r
		case_u
			add r4, r4, #-1 ; y—, r6=d
			add r6, r5, #1
			brnzp endswitch
		case_d
			add r4, r4, #1 ; y++, r6=u
			add r6, r5, #0
			brnzp endswitch
		case_l
			add r3, r3, #-1 ; x—, r6=r
			add r6, r5, #3
			brnzp endswitch
		case_r
			add r3, r3, #1 ; x++, r6=l
			add r6, r5, #2
			brnzp endswitch
	endswitch ; }
	;;; fill next spot’s x and y
	str r3, r2, #-2
	str r4, r2, #-1
	;;; fill cell with connection data
	add r1, r4, #0 ; cells[x, y][2+r6] = 1
	ld r0, board_width
	trap x2c
	add r1, r1, r3
	ld r0, cell_data_size
	trap x2c
	ld r0, cells
	add r1, r1, r0
	add r1, r1, r6
	add r5, r5, #1
	str r5, r1, #2
continue ; }while(r2!=stackstart)
ld r0, stackstart
add r0, r0, r2
brnp loop
and r0, r0, #0 ; fix the end of the stack
add r0, r0, #2
trap x26
and r1, r1, #0
str r1, r0, #0
add r1, r1, #1
str r1, r0, #0
ld r6, cells
ld r5, stackstart
draw_loop
	jsr showCell
	add r6, r6, #7
add r7, r6, r5
brnp draw_loop
HALT

stackstart .blkw 1
screen .fill x0300
cell_size .fill x0002
cell_color .fill x7fff
wall_color .fill x7a7e
board_width .fill x003d
cell_data_size .fill x0007 ; x, y, u, d, l, r, filled
cells .blkw 1

pushsurrounddata ;; r3 is x r4 is y, pushes: u d l r, r6 is surroundcount
st r0, pushsurrounddata0
st r1, pushsurrounddata1
st r5, pushsurrounddata5
st r7, pushsurrounddata7
and r0, r0, #0 ; push 4 0s
add r0, r0, #4
trap x26
and r5, r5, #0 ; set r5 to constant 0
and r6, r6, #0 ; r6 is surroundcount
add r4, r4, #0 ; if y=0 {
brnp pushsurrounddata_skip_0
str r5, r2, #0 ; u = 0
brnzp pushsurrounddata_skip_1 ; } else {
pushsurrounddata_skip_0
add r1, r4, #-1 ; r1=1-cells[x, y-1][6]
ld r0, board_width
trap x2c
add r1, r1, r3
ld r0, cell_data_size
trap x2c
ld r0, cells
add r1, r1, r0
ldr r1, r1, #6
not r1, r1
add r1, r1, #2
str r1, r2, #0 ; u=r1
add r6, r6, r1 ; surroundcount += r1
pushsurrounddata_skip_1 ; }
ld r7, board_width ; if y-board_width+1=0 {
not r7, r7
add r7, r7, #2
add r7, r7, r4
brnp pushsurrounddata_skip_2
str r5, r2, #1 ; d = 0
brnzp pushsurrounddata_skip_3 ; } else {
pushsurrounddata_skip_2
add r1, r4, #1 ; r1=1-cells[x, y+1][6]
ld r0, board_width
trap x2c
add r1, r1, r3
ld r0, cell_data_size
trap x2c
ld r0, cells
add r1, r1, r0
ldr r1, r1, #6
not r1, r1
add r1, r1, #2
str r1, r2, #1 ; d=r1
add r6, r6, r1 ; surroundcount += r1
pushsurrounddata_skip_3 ; }
add r3, r3, #0 ; if x=0 {
brnp pushsurrounddata_skip_4
str r5, r2, #2 ; l = 0
brnzp pushsurrounddata_skip_5 ; } else {
pushsurrounddata_skip_4
add r1, r4, #0 ; r1=1-cells[x-1, y][6]
ld r0, board_width
trap x2c
add r1, r1, r3
add r1, r1, #-1
ld r0, cell_data_size
trap x2c
ld r0, cells
add r1, r1, r0
ldr r1, r1, #6
not r1, r1
add r1, r1, #2
str r1, r2, #2 ; l=r1
add r6, r6, r1 ; surroundcount += r1
pushsurrounddata_skip_5 ; }
ld r7, board_width ; if x-board_width+1=0 {
not r7, r7
add r7, r7, #2
add r7, r7, r3
brnp pushsurrounddata_skip_6
str r5, r2, #3 ; r = 0
brnzp pushsurrounddata_skip_7 ; } else {
pushsurrounddata_skip_6
add r1, r4, #0 ; r1=1-cells[x, y+1][6]
ld r0, board_width
trap x2c
add r1, r1, r3
add r1, r1, #1
ld r0, cell_data_size
trap x2c
ld r0, cells
add r1, r1, r0
ldr r1, r1, #6
not r1, r1
add r1, r1, #2
str r1, r2, #3 ; r=r1
add r6, r6, r1 ; surroundcount += r1
pushsurrounddata_skip_7 ; }
ld r0, pushsurrounddata0
ld r1, pushsurrounddata1
ld r5, pushsurrounddata5
ld r7, pushsurrounddata7
ret
pushsurrounddata0 .blkw 1
pushsurrounddata1 .blkw 1
pushsurrounddata5 .blkw 1
pushsurrounddata7 .blkw 1


showCell ; r6 points to cell
st r0, showcell0
st r1, showcell1
st r2, showcell2
st r3, showcell3
st r4, showcell4
st r5, showcell5
st r7, showcell7
ldr r0, r6, #0 ; r2 = x*cell_size
ld r1, cell_size
trap x2c
add r2, r1, #0
ldr r1, r6, #1 ; r1 = y*cell_size
ld r0, cell_size
trap x2c
add r0, r2, #0 ; r0 = r2
ld r4, wall_color ; set fill
; u
ldr r5, r6, #2
brp showcell_skip_0
ld r2, cell_size
add r2, r2, #1
and r3, r3, #0
add r3, r3, #1
trap x30
showcell_skip_0
; d
ldr r5, r6, #3
brp showcell_skip_1
ld r2, cell_size
add r5, r1, #0
add r1, r1, r2
add r2, r2, #1
and r3, r3, #0
add r3, r3, #1
trap x30
add r1, r5, #0
showcell_skip_1
; l
ldr r5, r6, #4
brp showcell_skip_2
ld r3, cell_size
add r3, r3, #1
and r2, r2, #0
add r2, r2, #2
trap x30
showcell_skip_2
; r
ldr r5, r6, #5
brp showcell_skip_3
ld r3, cell_size
add r0, r0, r3
add r3, r3, #1
and r2, r2, #0
add r2, r2, #2
trap x30
showcell_skip_3
ld r0, showcell0
ld r1, showcell1
ld r2, showcell2
ld r3, showcell3
ld r4, showcell4
ld r5, showcell5
ld r7, showcell7
ret
showcell0 .blkw 1
showcell1 .blkw 1
showcell2 .blkw 1
showcell3 .blkw 1
showcell4 .blkw 1
showcell5 .blkw 1
showcell7 .blkw 1
