.text
path: 		.string "log.txt"
namefmt : 	.string "%s,"
scorefmt : 	.string "%.2f,"
timefmt :       .string "%.2f\n"
s1 = 16
s2 = s1 + 16
buf_s = s2 + 16 
// *** allocation size
alloc = - (16 + 7*8) & -16
dealloc = - alloc

	fp 	.req 	x29
	lr 	.req 	x30

	define(nwritten, w22)
	define(fd1, w21)
	define(buf_base1, x23)

	.balign 4
	.global logData
logData:
	stp     fp, lr, [sp, alloc]!
        mov     fp, sp
	//--------------------------
	stp 	x21, x22, [fp, s1]
	stp 	x23, x28, [fp, s2]
	mov 	x19, x0			// name
	fmov 	s8, s0			// score
	fmov 	s9, s1			// time
	//--------------------------
        mov     w0, -100
        ldr     x1, =path
        mov     w2, 01 | 0100 | 02000
        mov     w3, 0666
        mov     x8, 56
        svc     0
        mov     fd1, w0
        cmp     fd1, 0
        b.ge    open_worksLF
        b       lfs
open_worksLF:
        add     buf_base1, fp, buf_s

startLog:
bb:
	// 	name
	mov     x0, 	buf_base1                // buffer base
        ldr     x1, =namefmt                     // formate
        mov     x2, x19                        // nam
        bl      sprintf                         // callsprintf
        // Store the returned value of sprintf
        mov     x28, x0
        mov     w0, fd1                         // fd -- 1st arg
        mov     x1, buf_base1                   // buf_base -- 2nd arg
        mov     x2, x28                         // buf-size
        mov     x8, 64                          // write request
        svc     0                               // system call
        mov     nwritten, w0                    // #ofwritten bytes
        cmp     nwritten, w28                   // == ? then continue
        b.ne    lfs
cc:
	// 	score
	mov 	x0, buf_base1
	ldr 	x1, =scorefmt
        fcvt    d0, s8                      
        bl 	sprintf
	mov     x28, x0
        //      printf index (row #)
        mov     w0, fd1                          // fd -- 1st arg
        mov     x1, buf_base1                    // buf_base -- 2nd arg
        mov     x2, x28                         // buf-size
        mov     x8, 64                          // write request
        svc     0                               // system call
        mov     nwritten, w0                    // #ofwritten bytes
        cmp     nwritten, w28                   // == ? then continue
        b.ne    lfs
dd:	
	// 	time
        mov     x0, buf_base1
        ldr     x1, =timefmt
        fcvt    d0, s9
        bl      sprintf
        mov     x28, x0
        //      printf index (row #)
        mov     w0, fd1                          // fd -- 1st arg
        mov     x1, buf_base1                    // buf_base -- 2nd arg
        mov     x2, x28                         // buf-size
        mov     x8, 64                          // write request
        svc     0                               // system call
        mov     nwritten, w0                    // #ofwritten bytes
        cmp     nwritten, w28                   // == ? then continue
        b.ne    lfs

	//      *** close the file
endlog:
        mov     w0, fd1
        mov     x8,57
        svc     0
        b       stopLF
lfs:
	mov	w0, -1				// error

stopLF:
	ldp     x21, x22, [fp, s1]
        ldp     x23, x28, [fp, s2]
	ldp 	fp, lr, [sp], dealloc
	ret
