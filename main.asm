//=============================================
.data

.global lives
lives : .int 3
.global bombs
bombs : .int 0
.global doubleRange
doubleRange : .int 0
.global exitTile
exitTile : .int 0

.global MPX
MPX : .word 0

.global MPY
MPY : .word 0

.global score
score : .single 0r0.0

.global scoreCount
scoreCount : .int 0
.global bombsCount
bombsCount : .int 0
.global doubleRangeCount
doubleRangeCount : .int 0
.global livesCount
livesCount : .int 0

topvar : .int 0
topvar2: .int 0
        //--------------------------
.text

wrongInputfmt :         .string "Make sure you enter valid inputs ... \n"
output : 		.string "The result = %2.2f\n"
topq : 			.string "\n\nDo you want to display top scores?( 0 / 1 )\n"
topmsg :                .string ":::: Enter number of scores ::::\n"
fmtmsg : 		.string "%d"
exlines: 		.string "\n\n\n"
        //--------------------------
// *** Local Variables 
size = 16
playername = size + 8
t1 = playername + 8
// *** Allocation size
alloc = - (16 + 3*8) & -16
dealloc = - alloc
        //--------------------------

        define(fp, x29)        
        define(lr, x30)                
        define(row, w21)
        define(col, w22)
        define(offset, x23)

        .balign 4
        .global main
        //--------------------------
main:
        stp     fp, lr, [sp, alloc]!
        mov     fp, sp
        //      get argc & argv
        mov     w19, w0                         // argc
        mov     x20, x1                         // argv
        //      *** check value of argc
        b       checkARGC                       // To argc
start:
        //      get player name
        mov     x19,  8                     
        ldr     x19, [x20, x19]
        str     x19, [fp, playername]
        //--------------------------
        //      get row #
        mov     x19,  16                       
        ldr     x0, [x20, x19]                      
        bl      atoi                            
        mov     row, w0
        //--------------------------                                  
        //      get col #
        mov     x19,  24
        ldr     x0, [x20, x19]                     
        bl      atoi                            
        mov     col, w0
        //--------------------------
        //      check # of row               
        cmp     row, 5                         
        b.lt    wrong                           
        cmp     row, 100                         
        b.gt    wrong
        //--------------------------
        //      check # of col                  
        cmp     col, 5                         
        b.lt    wrong                           
        cmp     col, 100                        
        b.gt    wrong                          
        //--------------------------
        b       allocation
        //--------------------------
checkARGC:
        //      *** check argc
        cmp     w19, 4
        b.eq    start                           // argc == 4 ?? start ***      
        //      *** ELSE
wrong:
        ldr     x0, =wrongInputfmt              // load wrongARG
        bl      printf                          // call printf
        b       stop                            // stop the prog.
        //--------------------------
allocation:
        //      *** array[i][j]
        add     offset, fp, -4   
        //      size =  row * col * sizeOfFloat(4)                 
        mul     w19, row, col                   
        lsl     w19, w19, 2
        sub     x19, xzr, x19
        and     x19, x19, -16                    
        //      update size variable
        str     x19, [fp, size]
        //      *** update sp                
        add     sp, sp, x19
        //--------------------------
	mov 	x0, 0
	bl 	time
	str 	w0, [fp, t1]

        mov     w0, row
        mov     w1, col
        mov     x2, offset
        bl      init

        mov     w0, row
        mov     w1, col
        mov     x2, offset
        bl      display

	//      Ask for display top scores
	ldr     x0, =topq
        bl      printf

        ldr     x0, =fmtmsg
        ldr     x1, =topvar
        bl      scanf

        ldr     x1, =topvar

        ldr     x19, [x1]
        cmp     x19, 0
	b.eq 	cont

        ldr     x0, =topmsg
        bl      printf

        ldr     x0, =fmtmsg
        ldr     x1, =topvar
        bl      scanf

        ldr     x1, =topvar
        ldr     x19, [x1]
	mov     x0, x19
        bl      topScores

cont:

	ldr     x0, =exlines
        bl      printf

        mov     w0, row
        mov     w1, col
        mov     x2, offset
        bl      displayGame

	mov 	w0, row
	mov 	w1, col
	mov 	x2, offset
	bl 	askUser

	// 	log data to the log.txt
	mov 	x0, 0
	bl 	time
	mov 	w19, w0
	ldr 	w20, [fp, t1]
	bl	getScore 		// score
	ldr 	x0, [fp, playername]    // name
	sub 	x19, x19, x20
	ucvtf 	s1, w19			// Time
	bl 	logData


	ldr     x0, =exlines
        bl      printf

	//      Ask for display top scores
        ldr     x0, =topq
        bl      printf

        ldr     x0, =fmtmsg
        ldr     x1, =topvar2
        bl      scanf

        ldr     x1, =topvar2
        ldr     x9, [x1]

        cmp     x9, 0
        b.eq    stopDy

        ldr     x0, =topmsg
        bl      printf

        ldr     x0, =fmtmsg
        ldr     x1, =topvar2
        bl      scanf

        ldr     x1, =topvar2
        ldr     x19, [x1]
        mov     x0, x19
        bl      topScores
        //--------------------------
stopDy:
        ldr     x19, [fp, size]
        sub     x19, xzr, x19
        add     sp, sp, x19                     // deallocate space from the stck
        //--------------------------
stop:
        ldp     fp, lr, [sp], dealloc
        ret

//=============================================






