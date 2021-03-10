.data

stringTxt : .ascii ""
emptyTxt :  .ascii ""

.text

path : .string "log.txt"
error_msg : .string "Error ... %s\n "
output :        .string "%c"
newline:        .string "\n"
outputScore :   .string "\t%.2f\t"
s1 = 16
s2 = s1 + 16
s3 = s2 + 16
s4 = s3 + 16
s5 = s4 + 16
buffer_s = s5 + 16
namesOffset = buffer_s + 16                             // offset for 2D array
scoresOffset = namesOffset + 8                          // offset for 1D array
timesOffset  = scoresOffset + 8                         // offset for 1D array
size = timesOffset + 8                                  // Allocated size
docNum = size + 8                                       // required doc number

buffer_size = 1
AT_FDCWD = -100
nameLength = 10                                         // The length of the name

alloc = -(16 + 17*8) & -16
dealloc = -alloc
        fp      .req    x29
        lr      .req    x30
        //----------------------------
        define(fd, w21)
        define(offset, x22)
        define(buf_base, x23)
        define(stor, x24)
        define(c1, w25)
        define(c2, w26)
        define(i, w27)
        //----------------------------
        .global topScores
        .balign 4
        //----------------------------
topScores:
        stp     fp, lr, [sp, alloc]!
        mov     fp, sp
        //----------------------------
        stp     x19, x20, [fp, s1]
        stp     x21, x22, [fp, s2]
        stp     x23, x24, [fp, s3]
        stp     x25, x26, [fp, s4]
        stp     x27, x28, [fp, s5]
        str     w0, [fp, docNum]
        // call a function return the number of docs
        bl      numberOfDocuments
        mov     i, w0
        ldr     w19, [fp, docNum]
        cmp     w19, i
        b.le    AllocateSpace
        str     i, [fp, docNum]
        //----------------------------
AllocateSpace:
        // Allocate space
        // names[i][10]
        // offset of names[i][10]
        add     x19, fp, -1
        str     x19, [fp, namesOffset]
        // size of char names[i*10]
        mov     w19, nameLength
        mul     w19, w19, i
        str     x19, [fp, size]
        // offset of float scores[i]
        add     x19, x19, 4
        sub     x19, xzr, x19
        add     x19, fp, x19 
        str     x19, [fp, scoresOffset]
        // size of scores[i]
        lsl     w19, i, 2
        ldr     x20, [fp, size]
        add     x19, x19, x20
        str     x19, [fp, size]
        //      offset of float times[i]
        add     x19, x19, 4
        sub     x19, xzr, x19
        add     x19, fp, x19
        str     x19, [fp, timesOffset]
        //      size of times[i]
        lsl     w19, i, 2
        ldr     x20, [fp, size]
        add     x19, x19, x20
        str     x19, [fp, size]
        // calc. the whole required size
        ldr     x19, [fp, size]
        sub     x19, xzr, x19
        and     x19, x19, -16
        str     x19, [fp, size]
        add     sp, sp, x19
        //----------------------------
        //      open the file
        mov w0, AT_FDCWD                                                // 1st arg (cwd)
        adrp x1, path                                                   // 2nd arg (pathname)
        add x1, x1, :lo12: path
        mov w2, 0                                                       // 3rd arg (read-only)
        mov w3, 0                                                       // 4th arg (not used)
        mov x8, 56                                                      // openat I/O request - to open a file
        svc 0                                                           // Call system function
        mov fd, w0                                                      // Record FD
        cmp fd, 0                                                       // Check if File Descriptor = -1 (error occured)
        b.ge open_works                                                 // If no error branch over

        // Else print the error message
        adrp x0, error_msg                                              // Set 1st arg (high order bits)
        add x0, x0, :lo12:error_msg                                     // Set 1st arg (lower 12 bits)
        adrp x1, path                                                   // Set 2nd arg (high order bits)
        add x1, x1, :lo12:path                                          // Set 2nd arg (lower 12 bits)
        bl printf
        mov w0, -1                                                      // Return -1 and exit the program
        b exit

open_works:
        add buf_base, x29, buffer_s                                     // Calculate base address
        mov     c1, 0
        ldr     offset, [fp, namesOffset]
readLoop:
        // offset of name
        ldr     stor, =stringTxt
        ldr     x28, =emptyTxt
        str     x28, [stor]     
        mov     c2, 1
        //Read the file
top:
        mov     w0, fd                                                  // 1st arg (fd)
        mov     x1, buf_base                                            // 2nd arg (buffer)
        mov     w2, buffer_size                                         // 3rd arg (n) 
        mov     x8, 63                                                  // read I/O request
        svc     0                                                       // Call system function
        
        cmp     w0 , buffer_size                                        // If nread != buffersize
        b.ne    end                                                     // then read failed, so exit loop

        ldrb    w9, [buf_base]
      
        cmp     w9, 44
        b.eq    tab

        cmp     w9, 10
        b.eq    endOfTime

        cmp     c2, 1
        b.eq    storeName

        cmp     c2, 2
        b.eq    storeScore

        b       storeTime

storeName:
        strb    w9, [offset]
        add     offset, offset, -1
        b       top

storeScore:
        strb    w9, [stor]
        add     stor, stor, 1
        b       top

storeTime:
        strb    w9, [stor]
        add     stor, stor, 1
        b       top
//----------------------------
tab:
        cmp     c2, 1
        b.eq    endOfName

        cmp     c2, 2
        b.eq    endOfScore

        b       endOfTime

endOfName:
        strb    w9, [offset]
        add     w20, c1, 1

        mov     w19, 10
        mul     w19, w19, w20
        sub     x19, xzr, x19
        ldr     x20, [fp, namesOffset]
        add     offset, x19, x20

        add     c2, c2, 1
        b       top
endOfScore:
                // times[i] = atof()
        lsl     w19, c1, 2
        sub     x19, xzr, x19
        ldr     x20, [fp, scoresOffset]
        add     x19, x19, x20
        ldr     x0, =stringTxt
        bl      atof
        fcvt    s0, d0
        str     s0, [x19]
        ldr     stor, =stringTxt
        ldr     x28, =emptyTxt
        str     x28, [stor]
        add     c2, c2, 1
        b       top
endOfTime:
                // times[i] = atof()
        lsl     w19, c1, 2
        sub     x19, xzr, x19
        ldr     x20, [fp, timesOffset]
        add     x19, x19, x20
        ldr     x0, =stringTxt
        bl      atof
        fcvt    s0, d0
        str     s0, [x19]
        ldr     stor, =stringTxt
        ldr     x28, =emptyTxt
        str     x28, [stor]
        add     c1, c1, 1
readCond:
        mov     c2, 1
        cmp     c1, i
        b.lt    readLoop        
end:
        // Close the text file
        mov w0, fd
        mov x8, 57
        svc 0

        //----------------------------


// Sort Records ....
        define(j, w21)
        define(k, w22)
        define(off1, x23)
        define(off2, x24)
        define(l, w25)
        mov     j, 0
        mov     k, 0
sortLoop:
        add     k, j, 1
sortInner:
        //      off1 scores[j]
        lsl     w19, j, 2
        sub     off1, xzr, x19
        //      off2 Scores[k]
        lsl     w19, k, 2
        sub     off2, xzr, x19
        //      compare
        ldr     x19, [fp, scoresOffset]
        //      loadValues
        ldr     s16, [x19, off1]
        ldr     s17, [x19, off2]
        fcmp    s16, s17
        b.le    swap
        //      ELSE
        b       sortCondJ
swap:
        // [x19,off1] = s17
        str     s17, [x19, off1]
        // [x19, off2] = s16
        str     s16, [x19, off2]
        // change the value in times[j] and [k]
        ldr     x19, [fp, timesOffset]
        ldr     s16, [x19, off1]
        ldr     s17, [x19, off2]
        str     s17, [x19, off1]
        str     s16, [x19, off2]
        //  swap names[j] & [k]
        //  off1 --> names[j]
        mov     w19, nameLength
        mul     w19, w19, j
        sub     x19, xzr, x19
        ldr     x20, [fp, namesOffset]
        add     off1, x19, x20
        //  off2 --> names[j]
        mov     w19, nameLength
        mul     w19, w19, k 
        sub     x19, xzr, x19
        add     off2, x19, x20
        //  set counter l = 0
        mov     l, 0
swapLoop:
        // load 1 byte
        ldrb    w9, [off1]
        ldrb    w10, [off2]
        // swap
        strb    w10, [off1]
        strb    w9, [off2]
        // decement offsets
        add     off1, off1, -1
        add     off2, off2, -1
        // l++
        add     l, l, 1
swapCond:
        cmp     l, nameLength
        b.lt    swapLoop
sortCondJ:
        add     k, k, 1
        cmp     k, i
        b.lt    sortInner
sortCondI:
        add     j, j, 1
        add     w19, i, -1
        cmp     j, w19
        b.lt    sortLoop
        //----------------------------



        //----------------------------
        
        mov     j, 0
        ldr     k, [fp, docNum]

displayNames:
        mov     w19, 10
        mul     w19, j, w19
        sub     x19, xzr, x19
        ldr     x20, [fp, namesOffset]
        add     off1, x19, x20
innerLoop:
        ldrb    w1, [off1]
        add     off1, off1, -1
        cmp     w1, 44
        b.eq    displayNameCond
        ldr     x0, =output
        bl      printf
        b       innerLoop
displayNameCond:

	ldr     off1, [fp, scoresOffset]

	lsl     w19, j, 2
        sub     x19, xzr, x19
        ldr     s0, [off1, x19]

        ldr     x0, =outputScore
        fcvt    d0, s0
        bl      printf


	ldr     off1, [fp, timesOffset]

        ldr     s0, [off1, x19]
 
        ldr     x0, =outputScore
        fcvt    d0, s0
        bl      printf

        ldr     x0, =newline
        bl      printf

        add     j, j, 1
        cmp     j, k
        b.lt    displayNames

        //---------------------------

        ldr     x19, [fp, size]
        sub     x19, xzr, x19
        add     sp, sp, x19 

	ldp     x19, x20, [fp, s1]
        ldp     x21, x22, [fp, s2]
        ldp     x23, x24, [fp, s3]
        ldp     x25, x26, [fp, s4]
        ldp     x27, x28, [fp, s5]

        ldp     fp, lr, [sp], dealloc
        ret


//=========================================================

numOfLines :    .string "Number Of lines = %d\n"


s1 = 16
s2 = s1 + 16
s3 = s2 + 16
buffer_s = s3 + 16
buffer_size = 1
AT_FDCWD = -100

alloc = - ( 16 + 8*8 ) & -16
dealloc = - alloc

        define(fdr, w21)
        define(offsetr, x22)
        define(buf_baser, x23)

        .balign 4
numberOfDocuments:

        stp     fp, lr, [sp, alloc]!
        mov     fp, sp
        //----------------------------
        stp     x19, x20, [fp, s1]
        stp     x21, x22, [fp, s2]
        str     x23, [fp, s3]
        //----------------------------

        //      open the file
        mov     w0, AT_FDCWD                                            // 1st arg (cwd)
        adrp    x1, path                                                // 2nd arg (pathname)
        add     x1, x1, :lo12: path
        mov     w2, 0                                                   // 3rd arg (read-only)
        mov     w3, 0                                                   // 4th arg (not used)
        mov     x8, 56                                                  // openat I/O request - to open a file
        svc     0                                                       // Call system function
        mov     fdr, w0                                                 // Record FD
        cmp     fdr, 0                                                  // Check if File Descriptor = -1 (error occured)
        b.ge    open                                                    // If no error branch over

        // Else print the error message
        adrp    x0, error_msg                                           // Set 1st arg (high order bits)
        add     x0, x0, :lo12:error_msg                                 // Set 1st arg (lower 12 bits)
        adrp    x1, path                                                // Set 2nd arg (high order bits)
        add     x1, x1, :lo12:path                                      // Set 2nd arg (lower 12 bits)
        bl      printf
        mov     w0, -1                                                  // Return -1 and exit the program
        b       exit

open:
        add     buf_baser, x29, buffer_s                                // Calculate base address
        mov     x19, 0                                                  // x19 is the counter
topLines:

        mov     w0, fdr                                                 // 1st arg (fd)
        mov     x1, buf_baser                                           // 2nd arg (buffer)
        mov     w2, buffer_size                                         // 3rd arg (n) 
        mov     x8, 63                                                  // read I/O request
        svc     0                                                       // Call system function

        cmp     w0 , buffer_size                                        // If nread != buffersize
        b.ne    endLines                                                // then read failed, so exit loop

        ldrb    w20, [buf_baser]

        cmp     w20, 10                                                 // value of new line
        b.eq    counterLines
        b       topLines

counterLines:
        add     x19, x19, 1
        b       topLines


endLines:
        // Close the text file
        mov     w0, fd
        mov     x8, 57
        svc     0

	mov 	w0, w19

        ldp     x19, x20, [fp, s1]
        ldp     x21, x22, [fp, s2]
        ldr     x23, [fp, s3]
        ldp     fp, lr, [sp], dealloc
        ret

//=========================================================

