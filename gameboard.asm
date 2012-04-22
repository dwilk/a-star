#gameboard.asm
.data 
Sz: 	      .word   100
gameboard:    .word   0:99
a_star1:      .word   0:99
a_star2:      .word   0:99
a_star3:      .word   0:99
NL_size:      .word   10
NL:           .asciiz "\n"

.text
main:
lw $s7, Sz # get size of list
lw $s6, NL_size
move    $s1, $zero                 # set counter for # of elems printed
move    $s2, $zero                 # set offset from Array
move    $s3, $zero		   # line counter is zero
init:
li $s4, 36
li $s5, 360
li $t1, 1
sw $t1, gameboard($s4)
sw $t1, gameboard($s5)
j move_human_left

move_human_left:
sw $zero, gameboard($s4)
sub $s4, $s4, 4
li $t1, 1
sw $t1, gameboard($s4)
j move_human_down

move_human_down:
sw $zero, gameboard($s4)
add $s4, $s4, 40
li $t1, 1
sw $t1, gameboard($s4)
j move_human_right

move_human_right:
sw $zero, gameboard($s4)
add $s4, $s4, 4
li $t1, 1
sw $t1, gameboard($s4)
j move_human_up

move_human_up:
sw $zero, gameboard($s4)
sub $s4, $s4, 40
li $t1, 1
sw $t1, gameboard($s4)
j move_computer_right

I revised the code to allow for moving the game pieces.

Tim

move_computer_right:
sw $zero, gameboard($s5)
add $s5, $s5, 4
li $t1, 1
sw $t1, gameboard($s5)
j move_computer_up

move_computer_up:
sw $zero, gameboard($s5)
sub $s5, $s5, 40
li $t1, 1
sw $t1, gameboard($s5)
j move_computer_left

move_computer_left:
sw $zero, gameboard($s5)
sub $s5, $s5, 4
li $t1, 1
sw $t1, gameboard($s5)
j move_computer_down

move_computer_down:
sw $zero, gameboard($s5)
add $s5, $s5, 40
li $t1, 1
sw $t1, gameboard($s5)
j print_loop

print_loop:
bge $s1, $s7, print_loop_end # stop after last elem is printed
lw $a0, gameboard($s2)           # print next value from the list
li $v0, 1
syscall
addi $s1, $s1, 1               # increment the loop counter
addi $s2, $s2, 4         
addi $s3, $s3, 1      # step to the next array elem
bge $s3, $s6, new_line
j        print_loop # repeat the loop

new_line:
la       $a0, NL                   # print a newline
li $v0, 4
move $s3, $zero
syscall
j print_loop
print_loop_end:
