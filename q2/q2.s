.section .data
fmt:        .string "%d"
sp_fmt:     .string " %d"
nl:         .string "\n"
#declare legnth of array, result, stack..
.section .bss
arr:        .space 800
res:        .space 800
stk:        .space 800

.section .text
.global main

#We save callee-saved registers (s0-s4) and ra
#a0 has argc, a1 has argv

main:
    addi sp, sp, -48
    sd ra, 40(sp)
    sd s0, 32(sp)
    sd s1, 24(sp)
    sd s2, 16(sp)
    sd s3, 8(sp)
    sd s4, 0(sp)

    addi s0, a0, -1
    mv s1, a1
    blez s0, done

    li s2, 0

#Calculate address of argv[i+1] (skip program name
#Call atoi to convert to integer

parse:
    bge s2, s0, init
    addi t0, s2, 1
    slli t0, t0, 3
    add t0, s1, t0
    ld a0, 0(t0)
    call atoi
    la t1, arr
    slli t2, s2, 2
    add t1, t1, t2
#store result
    sw a0, 0(t1)
    addi s2, s2, 1
#jump back
    jal x0, parse
# s3 = &res
init:
    li s2, 0
    la s3, res

#Sets every res[i] = -1 (default when no greater element exists)
init_loop:
    bge s2, s0, algo
    slli t0, s2, 2
    add t0, s3, t0
    li t1, -1
    sw t1, 0(t0)
    addi s2, s2, 1
    jal x0, init_loop


#s4 tracks stack size (0 = empty)
#Start from rightmost element (i = n-1)
algo:
    li s4, 0
    addi s2, s0, -1

#Load arr[i] into t2
loop:
    bltz s2, output
    la t0, arr
    slli t1, s2, 2
    add t0, t0, t1
    lw t2, 0(t0)

pop:
#If stack empty, skip to push
    beqz s4, push
    la t0, stk
    addi t1, s4, -1
    slli t1, t1, 2
    add t0, t0, t1
    lw t3, 0(t0)
    la t0, arr
    slli t1, t3, 2
    add t0, t0, t1
#Get arr[stk.top()] - the actual value at that index
    lw t4, 0(t0)
#If arr[stk.top()] > arr[i], we found the next greater element Otherwise pop and repeat

    bgt t4, t2, setres
    addi s4, s4, -1
    jal x0, pop

setres:
    la t0, res
    slli t1, s2, 2
    add t0, t0, t1
    sw t3, 0(t0)

#Push current index i onto stack, then move to next element
push:
    la t0, stk
    slli t1, s4, 2
    add t0, t0, t1
    sw s2, 0(t0)
    addi s4, s4, 1
    addi s2, s2, -1
    jal x0, loop

output:
    li s2, 0
out_loop:
# if i >= n, done
    bge s2, s0, endout
    la t0, res
    slli t1, s2, 2
    add t0, t0, t1
 # a1 = res[i] (second arg to printf)
    lw a1, 0(t0)
    la a0, fmt
    bnez s2, use_sp
    jal x0, doprint
use_sp:
    la a0, sp_fmt
doprint:
    call printf
    addi s2, s2, 1
    jal x0, out_loop

endout:
    la a0, nl
    call printf

done:
    li a0, 0
    ld ra, 40(sp)
    ld s0, 32(sp)
    ld s1, 24(sp)
    ld s2, 16(sp)
    ld s3, 8(sp)
    ld s4, 0(sp)
    addi sp, sp, 48
    ret
