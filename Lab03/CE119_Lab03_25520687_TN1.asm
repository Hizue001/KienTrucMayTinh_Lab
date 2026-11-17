# CE119 LAB 03 - TN1
# MSSV: 25520687
# MARS 4.5: Delayed branching OFF.

.data
msg:    .asciiz "Ket qua: "
.text
.globl main
# main
# Tham so : khong
# Ket qua : in Ket qua: 11 va ket thuc chuong trinh
# Thanh ghi su dung: $a0, $v0, $s0, $ra
main:
        li    $a0, 5            # x = 5
        jal   outer             # v0 = outer(5)
        move  $s0, $v0
        li    $v0, 4
        la    $a0, msg
        syscall
        move  $a0, $s0
        li    $v0, 1
        syscall
        li    $v0, 10
        syscall
# outer(x) = inner(x) + 1
# Tham so : $a0 = x
# Tra ve  : $v0 = 2*x + 1
# Thanh ghi su dung: $a0, $v0, $sp, $ra
# Bao toan: $sp va $ra duoc khoi phuc truoc khi return
outer:
        addi  $sp, $sp, -4      # Cap khung 1 word
        sw    $ra, 0($sp)       # Luu dia chi tro ve main
        jal   inner
        addi  $v0, $v0, 1
        lw    $ra, 0($sp)       # Khoi phuc dia chi tro ve main
        addi  $sp, $sp, 4       # Thu hoi khung
        jr    $ra
# inner(x) = 2 * x
# Tham so : $a0 = x
# Tra ve  : $v0 = 2*x
# Thanh ghi su dung: $a0, $v0, $ra
# Thu tuc la, khong dung khung ngan xep
inner:
        add   $v0, $a0, $a0
        jr    $ra
