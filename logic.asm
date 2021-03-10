//=============================================
.text
result :        .string "The result = %3.3f\n"
// *** Save registers - 4
s1 = 16                
s2 = s1 + 16           
s3 = s2 + 16           
// *** Local Variables 
// 5
sum = s3 + 16           
count1 = sum + 4        
count2 = count1 + 4     
px = count2 + 4         
py = px + 4             
// *** Allocation size
alloc = - ( 16 + 7 * 8 + 5 * 4) & -16
dealloc = - alloc
//----------------------------------------------------
        define(fp, x29)        
        define(lr, x30)

        define(x, w19)        
        define(y, w20)                 
        
        define(row, w21)         
        define(col, w22)
        define(offset, x23)  
        
        define(temp, w24)      
        define(tempx, x24)      
//----------------------------------------------------
        .balign 4
        .global calculateScore

// (int x, int y, int row, int col, float *borad[][])
calculateScore:
        stp     fp, lr, [sp, alloc]!
        mov     fp, sp
        //--------------------------
        //      store reg.
        stp     x19, x20, [fp, s1]
        stp     x21, x22, [fp, s2]
        stp     x23, x24, [fp, s3]
        //      store parameters
        mov     x, w0
        mov     y, w1
        mov     row, w2
        mov     col, w3
        mov     offset, x4
        //      start the loops to calculate the score
        //      set counter1 = -1                       // the outer loop
        mov     temp, 0
        str     temp, [fp, sum]
        mov     temp, -1
        str     temp, [fp, count1]                      
        b       count1Condition
        //--------------------------
casesI:
        //      px = x+count1
        ldr     temp, [fp, count1]
        add     temp, x, temp                            
        str     temp, [fp, px]
        //      count2 = -1
        mov     temp, -1                                // the inner loop
        str     temp, [fp, count2]
        b       count2Condition
        //--------------------------
casesII:
        //      py = y + count2
        ldr     temp, [fp, count2]
        add     temp, y, temp                           
        str     temp, [fp, py]
//----------------------------------------------------
// *** IF           In rage or out of range ... CASE 1
        //      checkInput(px, py, row, col)

	ldr     w0, [fp, px]                           
        ldr     w1, [fp, py]
        mov     w2, row
        mov     w3, col                           
        bl      checkInput                              
        //      w0 == 0 --> out of range
        cmp     w0, 0
        b.eq    count2Increment

// *** ELSE IF       COVERED or not ... CASE 2
        //--------------------------
        //      get value of board[px,py]
        mov     w0, col
        ldr     w1, [fp, px]
        ldr     w2, [fp, py]
        mov     x3, offset
        bl      getValue
        //      covered(float value)
        bl      covered
        //      w0 == 0 --> it is uncover
        cmp     w0, 0
        b.eq    count2Increment
        //--------------------------
// *** ELSE      get its value or rewards ... CASE 3
        //       x0 != 0 --> it is a covered cell
        //--------------------------
        //      sign : sends the address of board[x][y]
        //      sign(float **value)
        mov     w0, col
        ldr     w1, [fp, px]
        ldr     w2, [fp, py]
        mov     x3, offset
        bl      getAddress
        bl      sign
        //--------------------------
        //      sum += s0 float
        ldr     s9, [fp, sum]                         
        fadd    s9, s9, s0                         
        str     s9, [fp, sum]
        //--------------------------
        //      direct(px, py)
        ldr     w0, [fp, px]
        ldr     w1, [fp, py]
        bl      direct
        //--------------------------
        //      w0 == 0 --> it is not direct
        cmp     w0, 0
        b.eq    count2Increment
        //--------------------------
        //      w0 != 0 --> it is direct [ Recursive call ]
        ldr     w0, [fp, px]
        ldr     w1, [fp, py]
        mov     w2, row
        mov     w3, col
        mov     x4, offset
        //      calculateScore(px, py, r, c, arr )
        bl      calculateScore                           // recursive call
        //--------------------------
        ldr     s9, [fp, sum]
        fadd    s9, s9, s0                         
        str     s9, [fp, sum]
        b       count2Increment
        //--------------------------
count2Increment:

        //      count2+= 1
        ldr     temp, [fp, count2]
        add     temp, temp, 1
        str     temp, [fp, count2]
count2Condition:

        //      count2 < 2
        ldr     temp, [fp, count2]
        cmp     temp, 2
        b.lt    casesII

        ldr     temp, [fp, count1]
        add     temp, temp, 1
        str     temp, [fp, count1]
count1Condition:

        cmp     temp, 2
        b.lt    casesI
        //--------------------------
        //      load reg.
        ldr     s0, [fp, sum]				// return sum
        ldp     x19, x20, [fp, s1]
        ldp     x21, x22, [fp, s2]
        ldp     x23, x24, [fp, s3]
        ldp     fp, lr, [sp], dealloc
        ret

//=============================================

// *** Save registers - 2
s1 = 16                 // 16 - 32 , = 16
// *** Local Variables 
r1 = s1 + 16
r2 = r1 + 4           
// *** Allocation size
alloc = - ( 16 + 2 * 8 + 2 * 4) & -16
dealloc = - alloc
        //--------------------------
// int direct(int x, int y)
direct:
        stp     fp, lr, [sp, alloc]!
        mov     fp, sp
        //--------------------------
        //      store reg.
        stp     x19, x20, [fp, s1]
        //      store parameters
        mov     x, w0
        mov     y, w1
        //--------------------------
        //      get MPX
        adrp    x0, MPX
        add     x0, x0, :lo12:MPX
        ldr     w9, [x0]
        //      r1 = abs(MPX - x)
        sub     w9, w9, x
        cmp     w9, 0
        b.lt    MPXpositive
        str     w9, [fp, r1]
        b       MPXcontinue
MPXpositive:
        sub     w9, wzr, w9
        str     w9, [fp, r1]
MPXcontinue:
        //--------------------------
        //      get MPY
        adrp    x0, MPY
        add     x0, x0, :lo12:MPY
        ldr     w9, [x0]
        //      r2 = abs(MPY - y)
        sub     w9, w9, y
        cmp     w9, 0
        b.lt    MPYpositive
        str     w9, [fp, r2]
        b       MPYcontinue
MPYpositive:
        sub     w9, wzr, w9
        str     w9, [fp, r2]
MPYcontinue:
        //--------------------------
        //      get doubleRange
        bl      getDoubleRange
        mov     w9, w0
        //--------------------------
        //      if r1 > doubleRange || r2 > doubleRange
        //      Then --> Border Point --> w0 = 0
        ldr     w10, [fp, r1]
        cmp     w10, w9
        b.gt    borderPoint
        ldr     w10, [fp, r2]
        cmp     w10, w9
        b.gt    borderPoint
        //-------------------------- 
        //      Else --> Direct [Recursive call needed] , w0 = 1
        //mov     w0, 1                                   // return directPoint
        mov     w0, 1
        b       stopDirect
borderPoint:        
        mov     w0, 0 	                                  // return borderPoint
        //--------------------------
stopDirect:
        //      load reg.
        ldp     x19, x20, [fp, s1]
        ldp     fp, lr, [sp], dealloc
        ret

//=============================================

// *** Local Variables 
// 8 bytes - 1
value = 16                      // address of value
// *** Allocation size
alloc = - ( 16 + 1 * 8) & -16
dealloc = - alloc
        //--------------------------
// **** float sign(float **value)
sign:
        stp     fp, lr, [sp, alloc]!
        mov     fp, sp
        //      store parameters
        str     x0, [fp, value]         // stror *value
        ldr     x9, [fp, value]         // **x9 is double Pointer
        ldr     s9, [x9]                // float value
        fcvtnu  w9, s9                  // int value
        //--------------------------
        // if w9 >= 17 --> Reward
        cmp     w9, 17
        b.ge    rewardGained
        //--------------------------
        // *** Else --> it is a vlue not a reward
        fcmp     s9, 0.0
        b.lt    valueNegative
        //      board[x][y] = 16
        ldr     x9, [fp, value]
        mov     x10, 16
        scvtf   s10, x10
        str     s10, [x9]
        fmov    s0, s9                          // return value
        b       stopSign
        //--------------------------
valueNegative:
        //      board[x][y] = -16
        ldr     x9, [fp, value]
        mov     x10, -16
        scvtf   s10, x10
        str     s10, [x9]
        fmov    s0, s9                          // return value
        b       stopSign
        //--------------------------
rewardGained:
        //      A reawrd effect

        ldr     x10, [fp, value]
        sub     x11, xzr, x9
        scvtf   s10, x11
        str     s10, [x10]


        sub     w9, w9, 17                      // value of reward - 17
        cmp     w9, 0
        b.eq    exitTileGained
        cmp     w9, 1
        b.eq    doubleRangeGined
        cmp     w9, 2
        b.eq    bombGained
        cmp     w9, 3
        b.eq    lifeGained
        //--------------------------
exitTileGained:
        //      exitTile++
        bl      updateExitTile
        b       stopReward
        //--------------------------
doubleRangeGined:
        //      doubleRangeCount++
//        bl      updateDoubleRangeCount

	mov     w9, 1
        adrp    x0, doubleRangeCount
        add     x0, x0, :lo12:doubleRangeCount
        ldr     w10, [x0]
        add     w9, w9, w10
        str     w9, [x0]
       
        b       stopReward
        //--------------------------
bombGained:
        // call randint(3) if value is == 1 bombsCount++
        // else bombs if value is 0 bombsCount-2 and if 2 then bombsCount-1

        mov     w0, 3
        bl      randomInt

        cmp     w0, 0
        b.eq    TwoBombLost
        cmp     w0, 1
        b.eq    OneBombGained
        // Else oneBombLost
        mov     w0, -1
        bl      updateBombsCount
        b       stopReward
TwoBombLost:
        mov     w0, -2
        bl      updateBombsCount
        b       stopReward
OneBombGained:
        mov     w0, 1
        bl      updateBombsCount
        b       stopReward
        //--------------------------
lifeGained:
        // call randint(2) if value is == 1 livesCount++
        // else livesCount--
        // ***NOTE  --> lives cannot be more than 5+

        mov     w0, 2
        bl      randomInt
        
        cmp     w0, 0
        b.eq    oneLifeGained
        // else oneLifeLost
        mov     w0, -1
        bl      updateLivesCount
        b       stopReward
oneLifeGained:
        mov     w0, 1
        bl      updateLivesCount 
        b       stopReward
        //--------------------------
stopReward:
        mov     w9, 0
        ucvtf   s0, w9
stopSign:
        ldp     fp, lr, [sp], dealloc
        ret
//=============================================

