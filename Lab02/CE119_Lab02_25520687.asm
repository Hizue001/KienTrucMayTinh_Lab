# CE119 LAB02 - TN2: stats and histogram
# MSSV: 25520687 (d = 7)
# MARS 4.5; ASCII output/comments
# To test T2 or T3, change TEST_CASE to 2 or 3 and Assemble again.
.eqv TEST_CASE 1

.data
S_T1:      .word 2, 10, 4, 5, 9, 1, 3, 9, 2, 5, 0, 10
S_T2:      .word 10
S_T3:      .word 4, 4, 4, 4, 4
# grade_tab[score] = group index, valid scores: 0..10
grade_tab: .byte 0,0,0,0,1,1,1,2,2,3,3
.align 2
hist:      .word 0, 0, 0, 0
str_min:   .asciiz "min="
str_max:   .asciiz " max="
str_g0:    .asciiz "g0="
str_g1:    .asciiz " g1="
str_g2:    .asciiz " g2="
str_g3:    .asciiz " g3="
newline:   .asciiz "\n"

.text
.globl main
main:
    # Choose one test input at assembly time.
    li   $t0, TEST_CASE
    li   $t1, 2
    beq  $t0, $t1, main_case2
    li   $t1, 3
    beq  $t0, $t1, main_case3
    la   $s0, S_T1
    li   $s1, 12
    j    main_selected
main_case2:
    la   $s0, S_T2
    li   $s1, 1
    j    main_selected
main_case3:
    la   $s0, S_T3
    li   $s1, 5
main_selected:
    # Reset hist to zero (also helps when using MARS reset/rerun).
    la   $t0, hist
    sw   $zero, 0($t0)
    sw   $zero, 4($t0)
    sw   $zero, 8($t0)
    sw   $zero, 12($t0)

    # stats(array, n) -> v0=min, v1=max
    move $a0, $s0
    move $a1, $s1
    jal  stats
    move $s2, $v0
    move $s3, $v1

    # histogram(array, n, grade_tab, hist)
    move $a0, $s0
    move $a1, $s1
    la   $a2, grade_tab
    la   $a3, hist
    jal  histogram

    la   $a0, str_min
    li   $v0, 4
    syscall
    move $a0, $s2
    li   $v0, 1
    syscall
    la   $a0, str_max
    li   $v0, 4
    syscall
    move $a0, $s3
    li   $v0, 1
    syscall
    la   $a0, newline
    li   $v0, 4
    syscall

    la   $s4, hist
    la   $a0, str_g0
    li   $v0, 4
    syscall
    lw   $a0, 0($s4)
    li   $v0, 1
    syscall
    la   $a0, str_g1
    li   $v0, 4
    syscall
    lw   $a0, 4($s4)
    li   $v0, 1
    syscall
    la   $a0, str_g2
    li   $v0, 4
    syscall
    lw   $a0, 8($s4)
    li   $v0, 1
    syscall
    la   $a0, str_g3
    li   $v0, 4
    syscall
    lw   $a0, 12($s4)
    li   $v0, 1
    syscall
    la   $a0, newline
    li   $v0, 4
    syscall

    li   $v0, 10
    syscall

# stats: scan n>=1 word elements once; do not modify memory
# Inputs : a0=array address; a1=element count (>=1)
# Outputs: v0=min; v1=max
# Clobbers: t0,t1,t2 (and a0,a1)
# Leaf procedure; no calls.
stats:
    lw   $v0, 0($a0)
    move $v1, $v0
    addiu $a0, $a0, 4
    addiu $a1, $a1, -1
stats_loop:
    beq  $a1, $zero, stats_done
    lw   $t0, 0($a0)
    slt  $t1, $t0, $v0
    beq  $t1, $zero, stats_max
    move $v0, $t0
stats_max:
    slt  $t2, $v1, $t0
    beq  $t2, $zero, stats_next
    move $v1, $t0
stats_next:
    addiu $a0, $a0, 4
    addiu $a1, $a1, -1
    j    stats_loop
stats_done:
    jr   $ra

# histogram: hist[grade_tab[score]]++ for each valid score 0..10
# Inputs : a0=array address, a1=n, a2=grade_tab, a3=hist
# Outputs: none; updates hist[0..3]
# Clobbers: t0,t1,t2,t3,t4 only; a0..a3 remain unchanged
# Leaf procedure; uses lbu lookup rather than threshold comparisons.
histogram:
    move $t0, $zero
hist_loop:
    beq  $t0, $a1, hist_done
    sll  $t1, $t0, 2
    addu $t1, $a0, $t1
    lw   $t2, 0($t1)
    addu $t3, $a2, $t2
    lbu  $t3, 0($t3)
    sll  $t3, $t3, 2
    addu $t3, $a3, $t3
    lw   $t4, 0($t3)
    addiu $t4, $t4, 1
    sw   $t4, 0($t3)
    addiu $t0, $t0, 1
    j    hist_loop
hist_done:
    jr   $ra
