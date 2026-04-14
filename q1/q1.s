.data
#globalising functions defined to be used later
.text
.globl make_node
.globl insert
.globl get
.globl getAtMost


#grows a stack by 32 bytes
#then storing doublewords at 8 byte intervals
make_node:
    addi sp, sp, -32
    sd   ra, 24(sp)
    sd   a1, 16(sp)

#a0 = 24
    li   a0, 24
#Returns a pointer to the new memory in a0
    call malloc

    ld   a1, 16(sp)
#Stores the integer value at offset 0 of the new node.
    sw   a1, 0(a0)
#sets left and right to 0
    sd   x0, 8(a0)
    sd   x0, 16(a0)

    ld   ra, 24(sp)
    addi sp, sp, 32
    ret

#insertion
#Allocates 48-byte frame.
insert:
    addi sp, sp, -48
    sd   ra, 40(sp)
    sd   s0, 32(sp)
    sd   s1, 24(sp)

    mv   s1, a1
#If root == NULL, jump to case_null to allocate a fresh node.

    beq  a0, x0, case_null

    mv   s0, a0
#Loads node->value (32-bit int) into t0
    lw   t0, 0(s0)
#go left, right according to insert value
    blt  s1, t0, go_left
    bgt  s1, t0, go_right
    mv   a0, s0
    jal x0,done_insert

#loads node->left at an offset of 8
go_left:
    ld   a0, 8(s0)
    mv   a1, s1
    call insert
#Stores the returned subtree root back into node->left
    sd   a0, 8(s0)
    mv   a0, s0
    jal x0,done_insert

#similar to left, but offset of 16 bits
go_right:
    ld   a0, 16(s0)
    mv   a1, s1
    call insert
    sd   a0, 16(s0)
    mv   a0, s0
    j    done_insert

#Root was NULL, so allocate a new node with the value.
case_null:
    mv   a1, s1
    call make_node

#restores all saved registers,pops frame,returns
done_insert:
    ld   s1, 24(sp)
    ld   s0, 32(sp)
    ld   ra, 40(sp)
    addi sp, sp, 48
    ret

#Same frame setup as insert
#If node is NULL, jump to return NULL
get:
    addi sp, sp, -48
    sd   ra, 40(sp)
    sd   s0, 32(sp)
    sd   s1, 24(sp)

    beq  a0, x0, key_absent

    mv   s0, a0
    mv   s1, a1
#Load node->value for comparison
    lw   t0, 0(s0)
#If equal → key_found. If search value < node value → go left. Otherwise fall through to get_r.
    beq  t0, s1, key_found
    blt  s1, t0, get_l

#Recurse right. Result (key_found node or NULL) comes back in a0.
get_r:
    ld   a0, 16(s0)
    mv   a1, s1
    call get
    j    end_get
#same as get_r
get_l:
    ld   a0, 8(s0)
    mv   a1, s1
    call get
    j    end_get

#if perfect match is key_found...
key_found:
    mv   a0, s0
    j    end_get
#not key_found..
key_absent:
    mv   a0, x0

#Restore registers, pop frame, return
end_get:
    ld   s1, 24(sp)
    ld   s0, 32(sp)
    ld   ra, 40(sp)
    addi sp, sp, 48
    ret


getAtMost:
    li   t2, -1

scan_loop:
    beq  a0, x0, scan_done

    lw   t0, 0(a0)

    ble  t0, a1, upd_ans

    ld   a0, 8(a0)
    jal x0, scan_loop

upd_ans:
    mv   t2, t0
    ld   a0, 16(a0)
    j    scan_loop

scan_done:
    mv   a0, t2
    ret
