# CE119 LAB 03 - TN2
# MARS 4.5: Default memory configuration, Delayed branching OFF.
# MSSV: 25520687; d = 7.
.data
test1:   .asciiz "kien truc may tinh"
test2:   .asciiz "mips"
test3:   .asciiz ""
test4:   .asciiz "a bc def"
# S(7) from Table 4.
personal: .asciiz "vi dieu khien co bo nho rat it"

.text
.globl main
main:
        j     tests             # For Table 10, change to: j personal_only

# Direct call from main, with no wrapper stack frame.
personal_only:
        la    $a0, personal
        jal   reverse_words
personal_return:
        la    $a0, personal
        jal   print_line
        j     program_exit

tests:
        la    $a0, test1
        jal   reverse_words
        la    $a0, test1
        jal   print_line

        la    $a0, test2
        jal   reverse_words
        la    $a0, test2
        jal   print_line

        la    $a0, test3
        jal   reverse_words
        la    $a0, test3
        jal   print_line

        la    $a0, test4
        jal   reverse_words
        la    $a0, test4
        jal   print_line

        la    $a0, personal
        jal   reverse_words
        la    $a0, personal
        jal   print_line

program_exit:
        li    $v0, 10
        syscall

# strlen
# Tham so : $a0 = dia chi chuoi ket thuc bang byte 0
# Tra ve  : $v0 = so ky tu truoc byte 0
# Thanh ghi: $t0, $t1, $v0; khong dung stack, khong sua $s
strlen:
        move  $t0, $a0
        move  $v0, $zero
sl_loop:
        lbu   $t1, 0($t0)
        beq   $t1, $zero, sl_done
        addiu $v0, $v0, 1
        addiu $t0, $t0, 1
        j     sl_loop
sl_done:
        jr    $ra

# rev_range
# Tham so : $a0 = dia chi dau, $a1 = dia chi cuoi (tinh ca hai)
# Tra ve  : khong; dao tai cho doan [$a0, $a1]
# Thanh ghi: $a0, $a1, $t0-$t2; khong dung stack, khong sua $s
# Neu dau >= cuoi (so sanh khong dau), khong truy cap bo nho.
rev_range:
        sltu  $t0, $a0, $a1
        beq   $t0, $zero, rr_done
rr_loop:
        lbu   $t1, 0($a0)
        lbu   $t2, 0($a1)
        sb    $t2, 0($a0)
        sb    $t1, 0($a1)
        addiu $a0, $a0, 1
        addiu $a1, $a1, -1
        sltu  $t0, $a0, $a1
        bne   $t0, $zero, rr_loop
rr_done:
        jr    $ra

# reverse_words
# Tham so : $a0 = dia chi chuoi .asciiz
# Tra ve  : khong; dao thu tu tu ngay tren chuoi dau vao
# Thanh ghi: $a0, $a1, $v0, $t0, $t1; cac thu tuc con dung $t0-$t2
# Bao toan : $s0-$s2, $ra, $sp
# Khung 16 byte: 0 -> $s2, 4 -> $s1, 8 -> $s0, 12 -> $ra
# $s0 = con tro duyet, $s1 = dau tu, $s2 = dia chi byte ket thuc
reverse_words:
        addiu $sp, $sp, -16
        sw    $ra, 12($sp)
        sw    $s0, 8($sp)
        sw    $s1, 4($sp)
        sw    $s2, 0($sp)

        move  $s0, $a0
        jal   strlen
        beq   $v0, $zero, rw_done  # Chuoi rong: khong goi rev_range
        addu  $s2, $s0, $v0       # Dia chi byte 0, khong dao byte nay

        move  $a0, $s0
        addiu $a1, $s2, -1
        jal   rev_range            # Dao toan bo chuoi

        move  $s1, $s0
rw_scan:
        beq   $s0, $s2, rw_last
        lbu   $t0, 0($s0)
        li    $t1, 32              # ASCII space
        beq   $t0, $t1, rw_space
        addiu $s0, $s0, 1
        j     rw_scan

rw_space:
        move  $a0, $s1
        addiu $a1, $s0, -1
        jal   rev_range            # Dao lai tu vua duyet
        addiu $s0, $s0, 1
        move  $s1, $s0
        j     rw_scan

rw_last:
        move  $a0, $s1
        addiu $a1, $s0, -1
        jal   rev_range            # Dao lai tu cuoi

rw_done:
        lw    $s2, 0($sp)
        lw    $s1, 4($sp)
        lw    $s0, 8($sp)
        lw    $ra, 12($sp)
        addiu $sp, $sp, 16
        jr    $ra

# print_line
# Tham so : $a0 = dia chi chuoi
# Tra ve  : khong; in |chuoi| va xuong dong
# Thanh ghi: $t4, $a0, $v0; thu tuc la, khong dung stack
print_line:
        move  $t4, $a0
        li    $v0, 11
        li    $a0, 124             # '|'
        syscall
        li    $v0, 4
        move  $a0, $t4
        syscall
        li    $v0, 11
        li    $a0, 124
        syscall
        li    $a0, 10              # Newline
        syscall
        jr    $ra