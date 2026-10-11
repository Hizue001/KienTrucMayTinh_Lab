.data
    # 15 not theo Bang 13 (Ode to Joy)
    pitches:        .word 64, 64, 65, 67, 67, 65, 64, 62, 60, 60, 62, 64, 64, 62, 62
    durations:      .word  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  3,  1,  4
    num_notes:      .word 15

    space_char:     .asciiz " "
    newline:        .asciiz "\n"
    msg_total_exp:  .asciiz "Tong du kien (ms): "
    msg_total_meas: .asciiz "Thoi gian do duoc (ms): "

.text
.globl main

main:
    # 1. Doc thoi gian bat dau bang syscall 30 ($a0 = 32 bit thap)
    addi $v0, $zero, 30
    syscall
    add  $s7, $a0, $zero            # $s7 = start_time

    la   $s0, pitches               # Dia chi mang pitches
    la   $s1, durations             # Dia chi mang durations
    lw   $s2, num_notes             # $s2 = 15
    addi $s3, $zero, 0              # $s3 = Tong thoi luong du kien (ms)
    addi $s4, $zero, 0              # $s4 = i = 0

note_loop:
    slt  $t0, $s4, $s2              # Neu i < 15 thi $t0 = 1, nguoc lai = 0
    beq  $t0, $zero, end_note_loop  # Het 15 not thi thoat vong lap

    # Doc pitch va dich giong (pitch = pitch + a, voi a = 7)
    lw   $t1, 0($s0)
    addi $t1, $t1, 7                # $t1 = cao do thuc phat

    # Doc duration va tinh thoi luong (ms = nhip * 230)
    lw   $t2, 0($s1)
    addi $t3, $zero, 230            # 1 nhip = 230 ms (b = 8)
    mult $t2, $t3
    mflo $t2                        # $t2 = thoi luong (ms)

    # Cong don thoi luong vao tong du kien
    add  $s3, $s3, $t2

    # In ra: <cao do> <ms>\n
    addi $v0, $zero, 1
    add  $a0, $t1, $zero
    syscall

    addi $v0, $zero, 4
    la   $a0, space_char
    syscall

    addi $v0, $zero, 1
    add  $a0, $t2, $zero
    syscall

    addi $v0, $zero, 4
    la   $a0, newline
    syscall

    # Phat am thanh: syscall 33 (blocking)
    add  $a0, $t1, $zero            # Cao do
    add  $a1, $t2, $zero            # Do dai (ms)
    addi $a2, $zero, 0              # Nhac cu: 0
    addi $a3, $zero, 100            # Am luong: 100
    addi $v0, $zero, 33             # Cau hinh A: 33
    syscall

    # Tang con tro mang (word = 4 bytes) va bien dem
    addi $s0, $s0, 4
    addi $s1, $s1, 4
    addi $s4, $s4, 1
    j    note_loop

end_note_loop:
    # 2. Doc thoi gian ket thuc bang syscall 30
    addi $v0, $zero, 30
    syscall
    sub  $s6, $a0, $s7              # $s6 = elapsed_time = end - start

    # In "Tong du kien (ms): <so>\n"
    addi $v0, $zero, 4
    la   $a0, msg_total_exp
    syscall

    addi $v0, $zero, 1
    add  $a0, $s3, $zero
    syscall

    addi $v0, $zero, 4
    la   $a0, newline
    syscall

    # In "Thoi gian do duoc (ms): <so>\n"
    addi $v0, $zero, 4
    la   $a0, msg_total_meas
    syscall

    addi $v0, $zero, 1
    add  $a0, $s6, $zero
    syscall

    addi $v0, $zero, 4
    la   $a0, newline
    syscall

    # Ket thuc
    addi $v0, $zero, 10
    syscall