.data
capacities:     .word 50, 50, 100, 100, 100, 9599
prices:         .word 1740, 1800, 2090, 2640, 2990, 3140
prompt_input:   .asciiz "Nhap so kWh (0..9999): "
msg_invalid:    .asciiz "Gia tri khong hop le, nhap lai.\n"
msg_res_prefix: .asciiz "Tien dien: "
msg_res_suffix: .asciiz " dong\n"

.text
.globl main

main:
input_loop:
    addi $v0, $zero, 4
    la   $a0, prompt_input
    syscall

    addi $v0, $zero, 5
    syscall
    add  $s0, $v0, $zero

    sltiu $t0, $s0, 10000
    bne   $t0, $zero, input_valid

    addi $v0, $zero, 4
    la   $a0, msg_invalid
    syscall
    j    input_loop

input_valid:
    addi $s1, $zero, 0
    la   $s2, capacities
    la   $s3, prices
    addi $s4, $zero, 6

calc_loop:
    slt  $t5, $zero, $s0
    beq  $t5, $zero, print_result

    slt  $t5, $zero, $s4
    beq  $t5, $zero, print_result

    lw   $t1, 0($s2)
    lw   $t2, 0($s3)

    slt  $t5, $t1, $s0
    beq  $t5, $zero, use_remain
    add  $t3, $t1, $zero
    j    accumulate

use_remain:
    add  $t3, $s0, $zero

accumulate:
    mult $t3, $t2
    mflo $t4
    add  $s1, $s1, $t4
    sub  $s0, $s0, $t3

    addi $s2, $s2, 4
    addi $s3, $s3, 4
    addi $s4, $s4, -1
    j    calc_loop

print_result:
    addi $v0, $zero, 4
    la   $a0, msg_res_prefix
    syscall

    addi $v0, $zero, 1
    add  $a0, $s1, $zero
    syscall

    addi $v0, $zero, 4
    la   $a0, msg_res_suffix
    syscall

    addi $v0, $zero, 10
    syscall
