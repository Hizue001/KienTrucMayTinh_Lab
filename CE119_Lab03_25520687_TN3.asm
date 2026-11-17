# CE119 LAB 03 - TN3
# MSSV: 25520687; d = 7; n(d) = 18.
# MARS 4.5, Default memory configuration, Delayed branching OFF.
.data
n_value: .word 20                # Change n here for Tables 12 and 13
msg_f:   .asciiz "F("
msg_eq:  .asciiz ") = "
newline: .asciiz "\n"

.text
.globl main
main:
        lw    $a0, n_value
        jal   fib_rec            # Change ONLY this target to fib_iter to compare
        move  $s0, $v0

        li    $v0, 4
        la    $a0, msg_f
        syscall
        li    $v0, 1
        lw    $a0, n_value
        syscall
        li    $v0, 4
        la    $a0, msg_eq
        syscall
        li    $v0, 1
        move  $a0, $s0
        syscall
        li    $v0, 4
        la    $a0, newline
        syscall
        li    $v0, 10
        syscall

# fib_rec: tinh F(n) bang hai loi goi de quy voi moi n >= 2
# Tham so : $a0 = n, n >= 0
# Tra ve  : $v0 = F(n)
# Thanh ghi: $a0, $v0, $t0, $s0, $s1, $ra, $sp
# Bao toan : $s0, $s1, $ra, $sp
# Khung 12 byte, ke ca truong hop co so:
#   0($sp) -> $s1 cu; 4($sp) -> $s0 cu; 8($sp) -> $ra
# $s0 = n cua lan goi hien tai; $s1 = F(n-1)
fib_rec:
        addiu $sp, $sp, -12
        sw    $ra, 8($sp)
        sw    $s0, 4($sp)
        sw    $s1, 0($sp)
        move  $s0, $a0

        slti  $t0, $s0, 2
        bne   $t0, $zero, fr_base

        addiu $a0, $s0, -1
        jal   fib_rec
        move  $s1, $v0           # Giu F(n-1) qua loi goi tiep theo
        addiu $a0, $s0, -2
        jal   fib_rec
        addu  $v0, $s1, $v0
        j     fr_done

fr_base:
        move  $v0, $s0           # Breakpoint Table 14: first instruction here

fr_done:
        lw    $s1, 0($sp)
        lw    $s0, 4($sp)
        lw    $ra, 8($sp)
        addiu $sp, $sp, 12
        jr    $ra

# fib_iter: tinh F(n) bang vong lap
# Tham so : $a0 = n    Tra ve : $v0 = F(n)
# Thanh ghi: $t0-$t3 (thu tuc la)
fib_iter:
        move  $v0, $zero        # a = F(0)
        li    $t0, 1            # b = F(1)
        move  $t1, $zero        # i = 0
fi_loop:
        slt   $t2, $t1, $a0
        beq   $t2, $zero, fi_done
        addu  $t3, $v0, $t0     # a + b
        move  $v0, $t0
        move  $t0, $t3
        addiu $t1, $t1, 1
        j     fi_loop
fi_done:
        jr    $ra
