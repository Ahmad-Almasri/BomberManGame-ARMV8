//=============================================

// *** String Literals
newline :               .string "\n"
value :                 .string " %2.2lf "
// *** save registers
s1 = 16
s2 = s1 + 16
s3 = s2 + 16
// ** local variable
i = s3 + 16
j = i + 4
// *** Allocation size
alloc = - (16 + 6*8 + 2*4) & -16
dealloc = - alloc
        //--------------------------
        define(fp, x29)
        define(lr, x30)
        define(row, w21)
        define(col, w22)
        define(offset, x23)
        //--------------------------
        .balign 4
        .global display
// void display(int r, int c, int *table)
display:
        stp     fp, lr, [sp, alloc]!
        mov     fp, sp
        //--------------------------
        //      store parameters
        mov     row, w0                    // r
        mov     col, w1                    // c
        mov     offset, x2                 // table offset
        //      save used registers
        stp     x19, x20, [fp, s1]
        stp     x21, x22, [fp, s2]
        str     x23, [fp, s3]
        //      set variables
        mov     w19, 0
        str     w19, [fp, i]                    // i = 0
        str     w19, [fp, j]                    // j = 0
        //--------------------------
displayLoop:
        mov     w0, col
        ldr     w1, [fp, i]
        ldr     w2, [fp, j]
        mov     x3, offset
        bl      getValue
        fmov    s16, s0
        //--------------------------
//        mov     x9, 17
//        ucvtf   s17, x9
//        fcmp    s16, s17
//        b.lt    printValue
//        bl      symbol
//	b 	goToJ
        // *** print -> table[i][j]
printValue:
        ldr     x0, =value
        fcvt    d0, s16
        bl      printf
        //--------------------------
        // *** check j
goToJ:
        ldr     w19, [fp, j]                    // get j
        add     w19, w19, 1                     // j++
        str     w19, [fp, j]                    // update j
        cmp     w19, col                        // compare j with c
        b.lt    displayLoop                     // j < c ?? initLoop
        //--------------------------
displayCond:
        // *** print newline
        ldr     x0, =newline
        bl      printf
        //--------------------------
        // *** set  j = 0
        mov     w19, 0
        str     w19, [fp, j]
        //--------------------------
        // *** i < r ??
        ldr     w19, [fp, i]                    // get i
        add     w19, w19, 1                     // i++
        str     w19, [fp, i]                    // update i
        cmp     w19, row                        // compare i with r
        b.lt    displayLoop                     // i < r ?? displayLoop
        //--------------------------
stopDisplay:
        ldp     x19, x20, [fp, s1]
        ldp     x21, x22, [fp, s2]
        ldr     x23, [fp, s3]
        ldp     fp, lr, [sp], dealloc
        ret

//=============================================
// *** String Literals
coveredTile :            .string " X "
v1 :            .string " + "
v2 :            .string " - "
v3 :            .string " * "
v4 :            .string " $ "
v5 :            .string " @ "
v6 :            .string " # "
// *** save registers
s1 = 16
s2 = s1 + 16
s3 = s2 + 16
// ** local variable
i = s3 + 16
j = i + 4
// *** Allocation size
alloc = - (16 + 7*8 + 2*4) & -16
dealloc = - alloc
//================================
        .balign 4
        .global displayGame
// void display(int r, int c, int *table)
displayGame:

        stp     fp, lr, [sp, alloc]!
        mov     fp, sp
        //      store parameters
        mov     row, w0                         // r
        mov     col, w1                         // c
        mov     offset, x2                         // table offset
        //      save used registers
        stp     x19, x20, [fp, s1]
        stp     x21, x22, [fp, s2]
        str     x23, [fp, s3]
        //      set variables
        mov     w19, 0
        str     w19, [fp, i]                    // i = 0
        str     w19, [fp, j]                    // j = 0
        //--------------------------
displayGameLoop:
        // *** calculate the offset [i][j]
        mov     w0, col
        ldr     w1, [fp, i]
        ldr     w2, [fp, j]
        mov     x3, offset
        bl      getValue
        fmov     s16, s0
        // make it global
        bl      covered
        //--------------------------
        cmp     w0, 0
        b.eq    pritnSymbol  
        ldr     x0, =coveredTile
        bl      printf
        b       checkJ
pritnSymbol:
        fmov    s0, s16
        bl      symbol 
        //--------------------------  
checkJ:
        // *** check j
        ldr     w19, [fp, j]                    
        add     w19, w19, 1                     
        str     w19, [fp, j]                                   
        cmp     w19, col                        // compare j with c
        b.lt    displayGameLoop                  
        //--------------------------
displayGameCond:
        // *** print newline
        ldr     x0, =newline
        bl      printf
        // *** set  j = 0
        mov     w19, 0
        str     w19, [fp, j]
        // *** i < r ??
        ldr     w19, [fp, i]    
        add     w19, w19, 1  
        str     w19, [fp, i]   
        cmp     w19, row                        // compare i with row
        b.lt    displayGameLoop 
        //--------------------------
stopDisplayGame:
        bl      displayData
        ldp     x19, x20, [fp, s1]
        ldp     x21, x22, [fp, s2]
        ldr     x23, [fp, s3]
        ldp     fp, lr, [sp], dealloc
        ret

//=============================================
        .balign 4
// **** void symbol()        
symbol:
        stp     fp, lr, [sp, -16]!
        mov     fp, sp
        //---------------------------
        fmov    s16, s0
        //---------------------------
        mov     x9, 16
        scvtf   s17, x9
        fcmp    s16, s17
        b.eq    positiveSymbol
        mov     x9, -16
        scvtf   s17, x9
        fcmp    s16, s17
        b.eq    negativeSymbol
        mov     x9, -17
        scvtf   s17, x9
        fcmp    s16, s17
        b.eq    exitTileSymbol
        mov     x9, -18
        scvtf   s17, x9
        fcmp    s16, s17
        b.eq    dollarSymbol
        mov     x9, -19
        scvtf   s17, x9
        fcmp    s16, s17
        b.eq    bombSymbol
        mov     x9, -20
        scvtf   s17, x9
        fcmp    s16, s17
        b.eq    lifeSymbol
        //---------------------------
positiveSymbol:
        ldr     x0, =v1
        bl      printf
        b       stopSymbol
negativeSymbol:
        ldr     x0, =v2
        bl      printf
        b       stopSymbol
exitTileSymbol:
        ldr     x0, =v3
        bl      printf
        b       stopSymbol
dollarSymbol:
        ldr     x0, =v4
        bl      printf
        b       stopSymbol
bombSymbol:
        ldr     x0, =v5
        bl      printf
        b       stopSymbol
lifeSymbol:
        ldr     x0, =v6
        bl      printf
        b       stopSymbol
        //---------------------------
stopSymbol:
        
        ldp     fp, lr, [sp], 16
        ret

//=============================================

// *** String Literals
livesfmt :              .string "\nLives : %d\n"
scorefmt :              .string "Score : %2.2f\n"
bombsfmt :              .string "Bombs : %d\n"
        .balign 4
        .global displayData
// **** void displayData()
displayData:
        stp     fp, lr, [sp,-16]!
        mov     fp, sp 
        //---------------------------
        bl      getLives
        mov     w1, w0
        ldr     x0, =livesfmt
        bl      printf

        bl      getScore
        fcvt    d0, s0
        ldr     x0, =scorefmt
        bl      printf

        bl      getBombs
        mov     x1, x0
        ldr     x0, =bombsfmt
        bl      printf
        //---------------------------
stopDisplayData:        
        ldp     fp, lr, [sp], 16
        ret

//============================================= 


