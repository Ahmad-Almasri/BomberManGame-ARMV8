//=============================================
.text
        .balign 4

        define(col, w9)
        define(i, w10)
        define(j, w11)
        define(offset, x12)

        .global getValue     
//getValue(col, i, j, offset)
getValue:


        // store parameters
        mov     col, w0
        mov     i, w1
        mov     j, w2
        mov     offset, x3
        // To load value of table[i][j]
        // [(i * col) + j] * -4
        mul     w13, i, col
        add     w13, w13, j
        lsl     x13, x13, 2
        sub     x13, xzr, x13
        ldr     s0, [offset, x13]              // return value

        ret

//=============================================

        .global getAddress
//getAddress(col, i, j, offset)
getAddress:

        // store parameters
        mov     col, w0
        mov     i, w1
        mov     j, w2
        mov     offset, x3

        // To load value of table[i][j]
        // [(i * col) + j] * -4
        mul     w13, i, col
        add     w13, w13, j
        lsl     x13, x13, 2
        sub     x13, xzr, x13
        add     x0, offset, x13

        ret

//=============================================
        .global getScore
getScore: 

        adrp    x11, score
        add     x11, x11, :lo12:score
        ldr     s0, [x11]

        ret
//=============================================
        .global getDoubleRange
getDoubleRange:

	adrp    x11, doubleRange
        add     x11, x11, :lo12:doubleRange
        ldr     w0, [x11]

        ret
//=============================================
        .global getExitTile
getExitTile: 

        adrp    x11, exitTile
        add     x11, x11, :lo12:exitTile
        ldr     w0, [x11]

        ret
//=============================================
        .global getLives
getLives: 

        adrp    x11, lives
        add     x11, x11, :lo12:lives
        ldr     w0, [x11]

        ret
//=============================================
        .global getBombs
getBombs: 

        adrp    x11, bombs
        add     x11, x11, :lo12:bombs
        ldr     w0, [x11]

        ret
//=============================================
scoremsg : .string ":: Note :: Score <= 0 :: 1 life is lost ::\n"
        .balign 4       
	.global updateScore
updateScore:

	stp     fp, lr, [sp,-16]!
        mov     fp, sp

        fmov    s16, s0
        adrp    x11, score
        add     x11, x11, :lo12:score
        ldr     s0, [x11]
        fadd    s0, s16, s0
        str     s0, [x11]

	fcmp 	s0, 0.0
	b.gt    stopUpdateScore
	// 	The score = 0
	// 	lives--
	mov 	w0, 0
	ucvtf 	s0, w0
	str 	s0, [x11]
	mov 	w0, -1
	bl 	updateLivesCount
	ldr 	x0, =scoremsg
	bl 	printf
stopUpdateScore:
	ldp     fp, lr, [sp], 16
        ret
//=============================================
drmsg : .string ":: UPDATE :: Value Of Gained Double Range ::  %d  ::\n"
        .balign 4
	.global updateDoubleRange
updateDoubleRange:

	stp 	fp, lr, [sp,-16]!
	mov 	fp, sp

        // power function
        adrp    x11, doubleRangeCount
        add     x11, x11, :lo12:doubleRangeCount
        ldr     w9, [x11]                        // power
	mov 	w10, 0
	str 	w10, [x11]
        mov     w10, 1                          // temp
        mov     w11, 2                          // base

        b       powerCond

powerStart:

        mul     w10, w10, w11 	                 // temp *= base
        add     w9, w9, -1                      // power += -1

powerCond:
        cmp w9, 1
        b.ge powerStart

        adrp    x11, doubleRange
        add     x11, x11, :lo12:doubleRange
        add     w10, w10, -1
        str     w10, [x11]

	cmp 	w10, 0
	b.eq 	stopUpdateDR
	ldr 	x0, =drmsg
	add 	x1, x10, 1
	bl 	printf
stopUpdateDR:
	ldp 	fp, lr, [sp], 16
        ret
//=============================================
        .global updateExitTile
updateExitTile:

        // exitTile+1 Only one exit tile
        adrp    x11, exitTile
        add     x11, x11, :lo12:exitTile
        mov     w9, 1

        str     w9, [x11]

        ret
//=============================================
livesmsg: .string ":: UPDATE :: Lives (+\/-) value ::  %d  ::\n"
	.balign 4
        .global updateLives
updateLives: 
	stp     fp, lr, [sp,-16]!
        mov     fp, sp

	// lives+= livesCount
        adrp    x11, livesCount
        add     x11, x11, :lo12:livesCount        
        ldr     w9, [x11]
	// reset livescount = 0
	mov 	w10, 0
	str 	w10, [x11]

        adrp    x11, lives
        add     x11, x11, :lo12:lives        
        ldr     w10, [x11]

        add     w10, w9, w10
        str     w10, [x11]
	
	ldr 	x0, =livesmsg
	mov 	x1, x9
	bl 	printf
	ldp 	fp, lr, [sp], 16
        ret
//=============================================
bombsmsg: .string ":: UPDATE :: Bombs (+\/-) value ::  %d  ::\n"
        .balign 4
        .global updateBombs
updateBombs:

	stp     fp, lr, [sp,-16]!
        mov     fp, sp

	// bombs+= bombsCount

        adrp    x11, bombsCount
        add     x11, x11, :lo12:bombsCount
        ldr     w9, [x11]
        // reset bombsCount = 0
        mov     w10, 0
        str     w10, [x11]

        adrp    x11, bombs
        add     x11, x11, :lo12:bombs
        ldr     w10, [x11]
        
        add     w10, w9, w10
        str     w10, [x11]

	ldr     x0, =bombsmsg
        mov     x1, x9
        bl      printf

        ldp     fp, lr, [sp], 16
        ret
//=============================================
        .global updateDoubleRangeCount
updateDoubleRangeCount:

        // doubleRangeCount+=1
        mov     w9, 1
        adrp    x11, doubleRangeCount
        add     x11, x11, :lo12:doubleRangeCount
        ldr     w10, [x11]
        add     w9, w9, w10
        str     w9, [x11]

        ret
//=============================================
        .global updateLivesCount
updateLivesCount: 

        // LivesCount+=1 || LivesCount-=1
        mov     w9, w0
        adrp    x11, livesCount
        add     x11, x11, :lo12:livesCount
        ldr     w10, [x11]
        add     w9, w9, w10
        str     w9, [x11]

        ret
//=============================================
        .global updateBombsCount
updateBombsCount:

        // Bombscout+=1 || Bombscout-=1 or 2
        mov     w9, w0
        adrp    x11, bombsCount
        add     x11, x11, :lo12:bombsCount
        ldr     w10, [x11]
        add     w9, w9, w10
        str     w9, [x11]

        ret
//=============================================
        .global setMP
setMP:
        // To set the main point (x, y)
        mov     w9, w0                  // MPX
        mov     w10, w10                // MPY

        adrp    x0, MPX
        add     x0, x0, :lo12:MPX
        str     w9, [x0]

        adrp    x0, MPY
        add     x0, x0, :lo12:MPY
        str     w10, [x0]

        ret
//=============================================

// int covered(float value)
        .global covered
covered:
        //      store parameters
        fmov     s17, s0
        mov      x9, 16
        scvtf    s18, x9
        //-------------------------- 
        //      if x9 == 16 | == -16 | <= -17
        //      Then it is uncovered
        fcmp     s17, s18
        b.eq    uncovered
        mov      x9, -16
        scvtf    s18, x9
        fcmp     s17, s18
        b.eq    uncovered
        mov      x9, -17
        scvtf    s18, x9
        fcmp     s17, s18
        b.le    uncovered
        mov     w0, 1                           // return 1 covered
        b       stopCovered
uncovered:
        mov     w0, 0                           // return 0 uncovered
stopCovered:
        ret

//==============================================
  	define(row, w13)
// int checkInput(int x, int y, int row, int col)
	.global checkInput
	.balign 4
checkInput:
        //      store parameters
        mov     i, w0
        mov     j, w1
        mov     row, w2
        mov     col, w3

        cmp     i, -1
        b.le    outOfRange
        cmp     i, row
        b.ge    outOfRange
        cmp     j, -1
        b.le    outOfRange
        cmp     j, col
        b.ge    outOfRange

        mov     w0, 1                                   // return 1 inRange
        ret
outOfRange:
        mov     w0, 0                                   // return 0 outOfRange
        ret

//=============================================

// **** int random(int value)
        .global randomInt
randomInt:
        stp     fp, lr, [sp, -16]!
        mov     fp, sp
        mov     x9, x0
        //--------------------------
        bl      rand
        udiv    w10, w0, w9
        mul     w10, w9, w10
        sub     w0, w0, w10
        //--------------------------
        ldp     fp, lr, [sp], 16
        ret
//===========================================

// **** float RandFloat(void)
        .global randFloat
randFloat:
        stp     fp, lr, [sp, -16]!
        mov     fp, sp
        //      rand() & 15
        bl      rand
        and     x9, x0, 15
        ucvtf   s16, w9
        //      ((float)rand()/(float)RAND_MAX)
        bl      rand
        ucvtf   s17, x0
        bl      randomInt
        ucvtf   s18, x0
        fdiv    s17, s18, s17                     // a value between 0 and 1
        //      s0 = s9 + s10
        fadd    s0, s16, s17

        ldp     fp, lr, [sp], 16
        ret
//===========================================



