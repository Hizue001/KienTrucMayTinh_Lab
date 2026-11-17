# CE119 LAB 03 - MO RONG
# MSSV: 25520687; n = 20 for the extension measurement.
# MARS 4.5, Default memory configuration, Delayed branching OFF.
.data
n_value: .word 20                # Extension: compare at n = 20
msg_f:   .asciiz "F("
msg_eq:  .asciiz ") = "
newline: .asciiz "\n"

.text
.globl main
main:
        lw    $a0, n_value
        jal   fib_opt            # Change ONLY this target to fib_rec to compare
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

# fib_opt: kiem tra n < 2 truoc khi cap khung
# Tham so : $a0 = n, n >= 0
# Tra ve  : $v0 = F(n)
# Thanh ghi: $a0, $v0, $t0, $s0, $s1, $ra, $sp
# Bao toan : $s0, $s1, $ra, $sp
# n < 2: khong cap khung, khong sua $s0/$s1/$ra.
# n >= 2: khung 12 byte, giong fib_rec.
# Moi lan goi khong co so van 19 lenh de so sanh rieng viec toi uu co so.
fib_opt:
        slti  $t0, $a0, 2
        bne   $t0, $zero, fo_base

        addiu $sp, $sp, -12
        sw    $ra, 8($sp)
        sw    $s0, 4($sp)
        sw    $s1, 0($sp)
        move  $s0, $a0

        addiu $a0, $s0, -1
        jal   fib_opt
        move  $s1, $v0
        addiu $a0, $s0, -2
        jal   fib_opt
        addu  $v0, $s1, $v0
        j     fo_done

fo_base:
        move  $v0, $a0           # Breakpoint: first base-case instruction
        jr    $ra                # No frame was allocated on this path

fo_done:
        lw    $s1, 0($sp)
        lw    $s0, 4($sp)
        lw    $ra, 8($sp)
        addiu $sp, $sp, 12
        jr    $ra
