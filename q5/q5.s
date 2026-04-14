.section .data
fname:      .string "input.txt"
fmode:      .string "r"
yes_msg:    .string "Yes\n"
no_msg:     .string "No\n"

.section .text
.global main

# main - opens file, checks if contents form a palindrome
# uses O(1) space by reading only 2 chars at a time with fseek
main:
    addi sp, sp, -48
    sd ra, 40(sp)
    sd s0, 32(sp)
    sd s1, 24(sp)
    sd s2, 16(sp)
    sd s3, 8(sp)
    sd s4, 0(sp)

    la a0, fname
    la a1, fmode
    call fopen
    mv s0, a0
    beqz s0, say_no

# get_length - seek to end and use ftell to get file size
get_length:
    mv a0, s0
    li a1, 0
    li a2, 2
    call fseek              # jump to end of file

    mv a0, s0
    call ftell
    mv s1, a0
    beqz s1, say_yes

# strip_trailing - remove trailing newlines and carriage returns from length
strip_trailing:
    mv a0, s0
    addi a1, s1, -1
    li a2, 0
    call fseek

    mv a0, s0
    call fgetc
    
    li t0, 10
    beq a0, t0, decrement_len
    li t0, 13
    beq a0, t0, decrement_len
    jal x0, init_pointers

# decrement_len - reduce effective length and continue stripping
decrement_len:
    addi s1, s1, -1
    bgtz s1, strip_trailing
    jal x0, say_yes

# init_pointers - set left=0 and right=len-1, handle single char case
init_pointers:
    li t0, 1
    ble s1, t0, say_yes
    li s2, 0
    addi s3, s1, -1

# loop - main palindrome check, compares chars from both ends moving inward
loop:
    bge s2, s3, say_yes

    mv a0, s0
    mv a1, s2
    li a2, 0
    call fseek              # seek to left position

    mv a0, s0
    call fgetc
    mv s4, a0

    li t0, 32
    beq s4, t0, skip_left
    li t0, 10
    beq s4, t0, skip_left
    li t0, 13
    beq s4, t0, skip_left
    li t0, 9
    beq s4, t0, skip_left
    jal x0, read_right

# skip_left - advance left pointer past whitespace
skip_left:
    addi s2, s2, 1
    jal x0, loop

# read_right - fetch character at right index and check for whitespace
read_right:
    mv a0, s0
    mv a1, s3
    li a2, 0
    call fseek              # seek to right position

    mv a0, s0
    call fgetc
    mv t2, a0

    li t0, 32
    beq t2, t0, skip_right
    li t0, 10
    beq t2, t0, skip_right
    li t0, 13
    beq t2, t0, skip_right
    li t0, 9
    beq t2, t0, skip_right
    jal x0, compare

# skip_right - move right pointer past whitespace
skip_right:
    addi s3, s3, -1
    jal x0, loop

# compare - check if left and right chars match, advance both pointers if so
compare:
    bne s4, t2, say_no
    addi s2, s2, 1
    addi s3, s3, -1
    jal x0, loop

# say_yes - close file and print "Yes"
say_yes:
    beqz s0, print_yes
    
    mv a0, s0
    call fclose

print_yes:
    la a0, yes_msg
    call printf
    jal x0, done

# say_no - close file and print "No"
say_no:
    beqz s0, print_no
    mv a0, s0
    call fclose

print_no:
    la a0, no_msg
    call printf

# done - restore stack and return 0
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
