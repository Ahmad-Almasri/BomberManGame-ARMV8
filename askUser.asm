.data

varX : .int 0
varY : .int 0

.text
//-----------------------------------
outFmt :			.string "The numbers are out of range .... \n\n"
uncoveredFmt:			.string "The cell is already uncovered\n\n"
scoreFmt: 			.string "\n\n\n\n:: UPDATE :: The current uncovered score ::  %2.2f  ::\n"
inputFmt: 			.string "\nEnter the (x , y) OR (50 , 50) to exit:\n"
format : 			.string "%d %d"
newlineData: 			.string "\n"
//-----------------------------------
// Allocation size
s1 = 16 			// To save registers
row = s1 + 16
col = row + 4
offset = col + 4

alloc = - (16 + 2*4 + 3*8) & -16
dealloc = - alloc
//-----------------------------------
	define(fp, x29)
	define(lr, x30)
	define(x, w19)
	define(y, w20)
//-----------------------------------
	.balign 4
	.global askUser
// void askUser(int row, int col, long offset)
//--------------------------------------------

askUser:

	stp	fp, lr, [sp, alloc]!
	mov 	fp, sp
	//-----------------------------------
	stp 	x19, x20, [fp, s1]
	str 	w0, [fp, row]
	str 	w1, [fp, col]
	str 	x2, [fp, offset]
	//-----------------------------------
askAgain:
	//	Ask for input
	ldr 	x0, =inputFmt
	bl 	printf

	ldr 	x0, =format
	ldr 	x1, =varX
	ldr 	x2, =varY
	bl 	scanf

	ldr 	x1, =varX
	ldr 	x, [x1]

	ldr 	x2, =varY
	ldr 	y, [x2]

	//-----------------------------------
	
	// If x and y == 50 the exit 
	cmp	x, 50
	b.eq 	checkY
	b 	InputTest
checkY:
	cmp	y, 50
	b.eq 	stopAskUser

	//-----------------------------------

InputTest:
	mov 	w0, x
	mov 	w1, y
	ldr 	w2, [fp, row]
	ldr 	w3, [fp, col]
	bl 	checkInput
	cmp 	w0, 0
	b.eq 	wrongInput

	// If input is correct chceck if it is covered or not
	// col i, j, offset
	ldr 	w0, [fp, col]
	mov 	w1, x
	mov	w2, y
	ldr 	x3, [fp, offset]
	bl 	getValue
	bl 	covered
	cmp 	w0, 0
	b.eq 	uncoveredCell

	// The choosen cell is correct then

	// set global variable
	adrp 	x0, MPX
	add 	x0, x0, :lo12:MPX
	str 	x, [x0]
	adrp 	x0, MPY
	add 	x0, x0, :lo12:MPY
	str 	y, [x0]

	// 	call calculateScore function
	mov 	w0, x
	mov 	w1, y
	ldr 	w2, [fp, row]
	ldr 	w3, [fp, col]
	ldr 	x4, [fp, offset]
	bl 	calculateScore
	fmov 	s8, s0

	ldr 	x0, =scoreFmt
	fcvt 	d0, s8
	bl  	printf

	fmov 	s0, s8
	bl	updateScore

	bl      updateData

	bl 	checkEnds

	cmp 	w0, 0
	b.eq 	stopAskUser

	ldr	w0, [fp, row]
        ldr     w1, [fp, col]
        ldr     x2, [fp, offset]
        bl      displayGame
	b 	askAgain
	//-----------------------------------
uncoveredCell:
	ldr 	x0, =uncoveredFmt
	bl 	printf
	b 	askAgain
	//-----------------------------------
wrongInput:
	ldr 	x0, =outFmt
	bl 	printf
	b 	askAgain
	//-----------------------------------

//--------------------------------------------
stopAskUser:

	ldr     w0, [fp, row]
        ldr     w1, [fp, col]
        ldr     x2, [fp, offset]
        bl      displayGame
	
	ldp 	x19, x20, [fp, s1]
	ldp 	fp, lr, [sp], dealloc

	ret
//====================================================


	.balign 4
updateData:

	stp 	fp, lr, [sp, -16]!
	mov 	fp, sp
	
	bl 	updateLives

	mov 	w0, -1
	bl 	updateBombsCount
	bl 	updateBombs

	bl 	updateDoubleRange

	ldr 	x0, =newlineData
	bl 	printf

	ldp 	fp, lr, [sp], 16
	ret 

//====================================================
l0: 		.string ":: UPDATE :: You won the game ::::  (*)\n\n"
l1: 		.string ":: UPDATE :: You lost ::::  Bombs (@) <= 0\n\n"
l2: 		.string ":: UPDATE :: You lost ::::  Lives <= 0\n\n"
	.balign 4
checkEnds:

	stp 	fp, lr, [sp, -16]!
	mov 	fp, sp
	// 	check exit tile FIRST
	// 	if exitTile == 1 --> The player won the game
	bl 	getExitTile
	cmp 	w0, 1
	b.ne 	checkBombs
	// ELSE
	ldr 	x0, =l0
	bl 	printf
	mov 	w0, 0
	b 	stopEnds
checkBombs:
	//	check # of bombs
	//	If bombs <= 0 --> The player lost the game
	bl 	getBombs
	cmp 	w0, 0
	b.gt 	checkLives
	// ELSE
	ldr 	x0, =l1
	bl 	printf
	mov 	w0, 0 				// stop the game
	b	stopEnds
checkLives:
	// 	check # of lives
	// 	If lives <= 0 --> The player lost the game
	bl 	getLives
	cmp 	w0, 0
	b.gt 	gameContinue
	// ELSE
	ldr 	x0, =l2
	bl	printf
	mov 	w0, 0
	b 	stopEnds
gameContinue:
	mov 	w1, 1
stopEnds:
	ldp 	fp, lr, [sp], 16
	ret

