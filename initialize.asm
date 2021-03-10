//===========================================

negFMT : 	.string "negative numbers :: %f :: %d ::\n"
rewFMT : 	.string "Reward numbers :: %f :: %d ::\n\n\n"

// *** Save registers - 4
s1 = 16
s2 = s1 + 16
s3 = s2 + 16
// *** Local Variables
//i = s3+8
i = s3 + 16
j = i + 4
// *** Allocation size
alloc = - ( 16 +  2 * 4 + 6 * 8) & -16
dealloc = - alloc
        //--------------------------
        define(fp, x29)
        define(lr, x30)

        define(row, w21)
        define(col, w22)
        define(arr, x23)
        //--------------------------
        .balign 4
        .global init
//**** init(int r, int c, float *board)
init:
        stp     fp, lr, [sp, alloc]!
        mov     fp, sp
        //      store reg.
        stp     x19, x20, [fp, s1]
        stp     x21, x22, [fp, s2]
        str     x23, [fp, s3]
        //      store parameters
        mov     row, w0
        mov     col, w1
        mov     arr, x2
        //--------------------------
        // set i & j = 0
        mov     w19, 0
        str     w19, [fp, i]
        str     w19, [fp, j]
        bl      clock
        bl      srand
initLoop:
        //      board[i][j] = randFloat()
        mov     w0, col
        ldr     w1, [fp, i]
        ldr     w2, [fp, j]
        mov     x3, arr
        bl      getAddress
        mov     x19, x0
        bl      randFloat
        str     s0, [x19]
        //--------------------------
        // *** check j
        ldr     w19, [fp, j]
        add     w19, w19, 1
        str     w19, [fp, j]
        cmp     w19, col
        b.lt    initLoop
initCond:
        // *** set j = 0
        mov     w19, 0
        str     w19, [fp, j]
        //--------------------------
        // *** i < row ??
        ldr     w19, [fp, i]
        add     w19, w19, 1
        str     w19, [fp, i]
        cmp     w19, row                        // compare i with row
        b.lt    initLoop
        //--------------------------
        // call addNegative
        mov     w0, row
        mov     w1, col
        mov     x2, arr
        bl      addNegative
        //--------------------------
        // call addNegative
        mov     w0, row
        mov     w1, col
        mov     x2, arr
        bl      addPacks
        //--------------------------
	// # of bombs is 5% of (rows*cols)
	//bombs = (((rows*cols)) * (5/100.0));
	mul     w19, row, col
        ucvtf   s16, w19
        mov     w9, 5
        mov     w10, 100
        ucvtf   s17, w9
        ucvtf   s18, w10
        fdiv    s17, s17, s18
        fmul    s16, s16, s17
        fcvtnu  w19, s16
	adrp 	x20, bombs
	add 	x20, x20, :lo12:bombs
	str 	w19, [x20]
	//--------------------------
initStop:
        ldp     x19, x20, [fp, s1]
        ldp     x21, x22, [fp, s2]
        ldr     x23, [fp, s3]

        ldp     fp, lr, [sp], dealloc
        ret
//===========================================
// *** Save registers - 4
s1 = 16
s2 = s1 + 16
s3 = s2 + 16
// *** Local Variables
counterNeg = s3+16
x = counterNeg + 4
y = x + 4
negValues = y + 4
// *** Allocation size
alloc = - ( 16 + 6 * 8 + 4 * 4) & -16
dealloc = - alloc
//----------------------------------------------------
//**** void addNegative(int r, int c, float *board)
addNegative:
        stp     fp, lr, [sp, alloc]!
        mov     fp, sp
        //--------------------------
        //      store reg.
        stp     x19, x20, [fp, s1]
        stp     x21, x22, [fp, s2]
        str     x23, [fp, s3]
        //      store parameters
        mov     row, w0
        mov     col, w1
        mov     arr, x2
        //      counterNeg = 0
        mov     w19, 0
        str     w19, [fp, counterNeg]
        //--------------------------
        //      negValues = (row*col) * 40%
        mul     w19, row, col
        ucvtf   s16, w19
        mov     w9, 40
        mov     w10, 100
        ucvtf   s17, w9
        ucvtf   s18, w10
        fdiv    s17, s17, s18
        fmul    s16, s16, s17
        fcvtnu  w19, s16
        str     w19, [fp, negValues]
	ldr 	x0, =negFMT
	fcvt 	d0, s17
	mov 	w1, w19
	bl 	printf
        //      print the negative value
        //--------------------------
addNegativeLoop:
        //      counterNeg == negValues -> Stop
        ldr     w19, [fp, counterNeg]
        ldr     w20, [fp, negValues]
        cmp     w19, w20
        b.eq    addNegativeStop
        //--------------------------
        mov     w0, row
        bl      randomInt
        str     w0, [fp, x]

        mov     w0, col
        bl      randomInt
        str     w0, [fp, y]

        mov     w0, col
        ldr     w1, [fp, x]
        ldr     w2, [fp, y]
        mov     x3, arr
        bl      getValue
        fmov    s16, s0
        //--------------------------
        //      if s16 > 0 -> make s16 negative
        fcmp     s16, 0.0
        b.gt    negativeValue
        b       addNegativeLoop
negativeValue:
        mov     w0, col
        ldr     w1, [fp, x]
        ldr     w2, [fp, y]
        mov     x3, arr
        bl      getAddress

        mov     x19, x0
        fneg    s16, s16
        str     s16, [x19]
        //--------------------------
        // ***  update counterNeg
        ldr     w19, [fp, counterNeg]
        add     w19, w19, 1
        str     w19, [fp, counterNeg]
        b       addNegativeLoop
addNegativeStop:
        ldp     x19, x20, [fp, s1]
        ldp     x21, x22, [fp, s2]
        ldr     x23, [fp, s3]
        ldp     fp, lr, [sp], dealloc
        ret
//===========================================
// *** Save registers - 4
s1 = 16
s2 = s1 + 16
s3 = s2 + 16
// *** Local Variables
packsCounter = s3 + 16
x = packsCounter + 4
y = x + 4
packValue = y + 4
numberOfPacks = packValue + 4
// *** Allocation size
alloc = - ( 16 + 6 * 8 + 5 * 4) & -16
dealloc = - alloc
//----------------------------------------------------
//**** void addPacks(int r, int c, float *board)
addPacks:
        stp     fp, lr, [sp, alloc]!
        mov     fp, sp
        //--------------------------
        //      store reg.
        stp     x19, x20, [fp, s1]
        stp     x21, x22, [fp, s2]
        str     x23, [fp, s3]
        //      store parameters
        mov     row, w0
        mov     col, w1
        mov     arr, x2
        //      counter = 0
        mov     w19, 0
        str     w19, [fp, packsCounter]
        //      packValue = 17
        mov     w19, 17
        str     w19, [fp, packValue]
        //--------------------------
        //      numberOfPacks = (row*col) * 20%
        mul     w19, row, col
        ucvtf   s16, w19
        mov     w9, 20
        mov     w10, 100
        ucvtf   s17, w9
        ucvtf   s18, w10
        fdiv    s17, s17, s18
        fmul    s16, s16, s17
        fcvtnu  w19, s16
        str     w19, [fp, numberOfPacks]
	ldr     x0, =rewFMT
        fcvt    d0, s17
	mov 	w1, w19
        bl      printf
        //      print the number of added packs
        //--------------------------
addPacksLoop:
        //      packsCounter == PacValues -> Stop
        ldr     w19, [fp, packsCounter]
        ldr     w20, [fp, numberOfPacks]
        cmp     w19, w20
        b.eq    addPacksStop
        //--------------------------
        mov     w0, row
        bl      randomInt
        str     w0, [fp, x]

        mov     w0, col
        bl      randomInt
        str     w0, [fp, y]

        mov     w0, col
        ldr     w1, [fp, x]
        ldr     w2, [fp, y]
        mov     x3, arr
        bl      getValue
        fmov     s16, s0
        //--------------------------
        //      if s16 > 0 -> make s16 a reward
        fcmp     s16, 0.0
        b.lt    addPacksLoop
        mov     x9, 17
        ucvtf   s17, x9
        fcmp    s16, s17
        b.ge    addPacksLoop
rewardValue:
        mov     w0, col
        ldr     w1, [fp, x]
        ldr     w2, [fp, y]
        mov     x3, arr
        bl      getAddress
        mov     x19, x0
        ldr     w20, [fp, packValue]
        ucvtf   s16, w20
        str     s16, [x19]                         // board[x][y] = packValue
        //--------------------------
        //      if packValue > 20
        //      Then packValue = 18
        add     w20, w20, 1                             // packValue++
        cmp     w20, 20
        b.gt    resetPackValue
        str     w20, [fp, packValue]                    // packValue++
        b       updatePacksCounter
        //--------------------------
resetPackValue:
        mov     w20, 18
        str     w20, [fp, packValue]
updatePacksCounter:
        ldr     w19, [fp, packsCounter]
        add     w19, w19, 1
        str     w19, [fp, packsCounter]
        b       addPacksLoop
addPacksStop:
        ldp     x19, x20, [fp, s1]
        ldp     x21, x22, [fp, s2]
        ldr     x23, [fp, s3]
        ldp     fp, lr, [sp], dealloc
        ret
//===========================================

