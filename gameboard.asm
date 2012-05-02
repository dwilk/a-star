#gameboard.asm

#$s0 - Computer's Roll
#s1 - Used for Printing
#$s2 - Used for Printing
#$s3 - Used for Printing
#$s4 - Human Piece
#$s5 - Computer Piece
#$s6 - New Computer Location
#$s7 - Human's Roll

#-Call Computer Roll
#-Create loop for movement (computer move)
#-Populate $s6 before you move
#-Create a "game over" state (compare $s4 and $s5) (+10,-10,+1,-1)

.data 
Sz: 	      .word   100
gameboard:    .word   0:100	#There is a buffer here there really only needs to be 99
a_star1:      .word   0:297	#These are three bytes wide: ADDR	HUER	PARENT
openCount:	.word	0:1
extendCount:	.word	0:1
currentSquare:	.word	0:1
hasPlayerGone:	.word	0:1
#NL_size:      .word   10
NL:           .asciiz "\n"
int_value:    .word   2
three:        .word   3

ask_input:
.asciiz "\Please Enter a value from 0-99\n"

begin_game0:
.asciiz "\You rolled the die. You have:\n"

begin_game1:
.asciiz "\ moves to go\n"

computer_rolls:
.asciiz "\ The Computer Rolled and has:\n"

please_move:
.asciiz "\To move, press 1 to go left, press 2 to go right, press 3 to go up, press 4 to go down\n"

print_invalid_move:
.asciiz "\Invalid Move\n"

print_game_over:
.asciiz "\Game Over - The computer caught you from an adjacent spot\n"

pathfound:
.asciiz "\PATH FOUND\n"

.text
main:
#lw $s7, Sz # get size of list
#lw $s6, NL_size

la $a0, currentSquare
li $t0, 90
sw $t0, 0($a0)			# initialize the currentSquare to 90

la $a0, hasPlayerGone
li $t0, 0
sw $t0, 0($a0)			#initialize the hasPlayerGone Boolean

move    $s1, $zero                 # set counter for # of elems printed
move    $s2, $zero                 # set offset from Array
move    $s3, $zero		   # line counter is zero
move    $s6, $zero                 # counter for number of obstacles
move    $s7, $zero

init: #initializes the gameboard
li $a1, 100
li $v0, 42
syscall
lw $t1, three
li $t2, 4
multu $a0, $t2
mflo $t3
sw $zero, gameboard,($t3)
sw $t1, gameboard($t3)
addi $t4, $t4, 1
bge $t4, 10, init_pieces
j init

init_pieces: #initializes the gameboard
li $s4, 36
li $s5, 360
li $t1, 1
li $t2, 2
sw $t1, gameboard($s4)
sw $t2, gameboard($s5)
j print_loop

invalid_move:
la $a0, print_invalid_move #prints a message to the user saying their move is invalid
li $v0, 4
syscall
addi $s7, $s7, 1
j print_loop 

move_human_left:
sub $t4, $s4, 4
lw $t2, gameboard($t4)
lw $t3, three
beq $t2, $t3, invalid_move
sw $zero, gameboard($s4)
sub $s4, $s4, 4
li $t1, 1
sw $t1, gameboard($s4)
j print_loop

move_human_down:
add $t4, $s4, 40
lw $t2, gameboard($t4)
lw $t3, three
beq $t2, $t3, invalid_move
sw $t0, gameboard($s4)
#beq $t0, 3, invalid_move
sw $zero, gameboard($s4)
add $s4, $s4, 40
li $t1, 1
sw $t1, gameboard($s4)
j print_loop

move_human_right:
add $t4, $s4, 4
lw $t2, gameboard($t4)
lw $t3, three
beq $t2, $t3, invalid_move
sw $t0, gameboard($s4)
#beq $t0, 3, invalid_move
sw $zero, gameboard($s4)
add $s4, $s4, 4
li $t1, 1
sw $t1, gameboard($s4)
j print_loop

move_human_up:
sub $t4, $s4, 40
lw $t2, gameboard($t4)
lw $t3, three
beq $t2, $t3, invalid_move
sw $t0, gameboard($s4)
#beq $t0, 3, invalid_move
sw $zero, gameboard($s4)
sub $s4, $s4, 40
li $t1, 1
sw $t1, gameboard($s4)
j print_loop

#move_computer_right:
#sw $zero, gameboard($s5)
#add $s5, $s5, 4
#li $t1, 2
#sw $t1, gameboard($s5)
#j move_computer_up

#move_computer_up:
#sw $zero, gameboard($s5)
#sub $s5, $s5, 40
#li $t1, 2
#sw $t1, gameboard($s5)
#j move_computer_left

#move_computer_left:
#sw $zero, gameboard($s5)
#sub $s5, $s5, 4
#li $t1, 2
#sw $t1, gameboard($s5)
#j move_computer_down

#move_computer_down:
#sw $zero, gameboard($s5)
#add $s5, $s5, 40
#li $t1, 2
#sw $t1, gameboard($s5)
#j print_loop

place_computer:
sw $zero, gameboard($s5) 	#make sure the new value is in $s6,
li $t2, 4			#then call this method to move the computer into any spot it wants
multu $s6, $t2			#(0-99)
mflo $t3
move $s5, $t3
li $t4, 2
sw $t4, gameboard($s5)
sub $s0, $s0, 1
move $s1, $zero #clears the printing array
move $s2, $zero #clears the printing array
move $s3, $zero #clears the printing array
j comp_print_loop

comp_print_loop:
la $a0, hasPlayerGone
li $t0, 0
sw $t0, 0($a0)	
bge $s1, 100, computerReady # stop after last elem is printed
lw $a0, gameboard($s2)           # print next value from the list
li $v0, 1
syscall
addi $s1, $s1, 1               # increment the loop counter
addi $s2, $s2, 4         
addi $s3, $s3, 1      # step to the next array elem
bge $s3, 10 , comp_new_line
j        comp_print_loop # repeat the loop

comp_new_line:
la       $a0, NL                   # print a newline
li $v0, 4
move $s3, $zero
syscall
j comp_print_loop

print_loop:
bge $s1, 100, roll_dice_human # stop after last elem is printed
lw $a0, gameboard($s2)           # print next value from the list
li $v0, 1
syscall
addi $s1, $s1, 1               # increment the loop counter
addi $s2, $s2, 4         
addi $s3, $s3, 1      # step to the next array elem
bge $s3, 10 , new_line
j        print_loop # repeat the loop

new_line:
la       $a0, NL                   # print a newline
li $v0, 4
move $s3, $zero
syscall
j print_loop

roll_dice_computer:
bgt $s0, 0, ready
li $a1, 5
li $v0, 42
syscall
move $s0, $a0
addi $s0, $s0, 1
j computerReady

computerReady:
add $t4, $s4, 0			# Player location
add $t5, $s5, 0			# Computer player location

div $t4, $t4, 4
div $t5, $t5, 4

div $t6, $t5, 10
mul $t7, $t6, 10
sub $t7, $t5, $t7

li $t1, 9
#Check Left 
beqz $t7, check2
sub $t0, $t5, 1
beq $t0, $t4, game_over

check2:
#Check Right
beq $t7, $t1, check3
add $t0, $t5, 1
beq $t0, $t4, game_over

#Check Up
check3:
beqz $t6, check4
sub $t0, $t5, 10
beq $t0, $t4, game_over

check4:
#Check Down
beq $t6, $t1, computerReady2
add $t0, $t5, 10
beq $t0, $t4, game_over

computerReady2:
beqz $s0, roll_dice_human
#beqz $s0, print_loop 
la $a0, computer_rolls #prints out a user message
li $v0, 4
syscall
li $v0, 1
move $a0, $s0
syscall
la $a0, NL #prints out a new line
li $v0, 4
syscall
la $a0, begin_game1 #prints out a user message
li $v0, 4
syscall
move $s1, $zero #clears the printing array
move $s2, $zero #clears the printing array
move $s3, $zero #clears the printing array
j startA

roll_dice_human:
bgt $s7, 0, ready
la $a1, hasPlayerGone
lw $a1, 0($a1)
bnez $a1, roll_dice_computer	# if the player has gone, it is time for the computer
li $a1, 5
li $v0, 42
syscall
move $s7, $a0
addi $s7, $s7, 1

ready:
beq $s7, 0, game_over #checks the number of human rolls
move $s1, $zero #clears the printing array
move $s2, $zero #clears the printing array
move $s3, $zero #clears the printing array
la $a0, begin_game0 #prints out a user message
li $v0, 4
syscall
li $v0, 1
move $a0, $s7
syscall
la $a0, NL #prints out a new line
li $v0, 4
syscall
la $a0, begin_game1 #prints out a user message
li $v0, 4
syscall
la $a0, hasPlayerGone
li $t0, 1
sw $t1, 0($a0)		#adjust the hasPlayerGone Boolean I did at this arbitrary spot within the movements of a player
la $a0, please_move #prints out a user message
li $v0, 4
syscall
li $v0, 5
syscall
move $t0, $v0
subi $s7, $s7, 1
beq $t0, 4, move_human_down #checks user input and does appropriate response
beq $t0, 3, move_human_up
beq $t0, 2, move_human_right
beq $t0, 1, move_human_left





startA:

la $a3, currentSquare
div $t0, $s5, 4
sw $t0, 0($a3)
la $a3, openCount
li $t0, 0
sw $t0, 0($a3)
j findOpen

###########################################
# ADD SQUARES TO OPEN LIST
###########################################

findOpen:
la $a3, currentSquare
lw $t7, 0($a3)			# $t7 has the address of the computer's current square

li $s6, 10
div $t5, $t7, 10		# t5 = t7 / 10 = y coordinate of computer's square
mflo	$t5
mul $t5, $t5, 10		# temporarily make t5 = t5 * 10		
sub $t6, $t7, $t5		# t6 = t7 - t5 which gets the remainder (basically is t7 mod 10) which is the x coordinate
div $t5, $t5, 10		# t5 has y coordinate of computer's square 
j canUp

###########################################
# ADD SQUARE ABOVE CURRENT LOCATION IF POSSIBLE
#	Check if it is in bounds 		(canUp)	
#	Check if it is open			(canUp)
#	Check if it has not already been added	(upCheck)
###########################################

canUp:
beqz $t5, canDown		#if the y coord is 0 check to see if you can move down
sub $t4, $t7, 10		#t4 has the whole coord of the potentially open square

la $a0, gameboard		# a0 is starting address of gameboard array
mul $t4, $t4, 4			# t4 is offset
add $a0, $t4, $a0		# a0 is address in gameboard array for potential open square

lw $t4, 0($a0)			# t4 is now 0,1,2, or 3 for open, player, computer, or barrier

bnez $t4, canDown		# if it is not 0 or open then check down

la $a1, a_star1			# start of open list

la $a2, openCount
lw $t4, 0($a2)
add $t1, $t4, 0
mul $t4, $t4, 12		# open list items are 3 bytes wide

add $a1, $a1, $t4		#address of open list item

li $t0, 0
la $a3, a_star1

j upCheck

# if openlist contains this square skip the adding of it to the openlist
upCheck:
beq $t0, $t1, upResume		# t0 is counter t1 is # of items already in openlist 
lw $t3, 0($a3)
beq $t3, $a0, canDown		# This square is already in the openlist
add $t0, $t0, 1			# increment the counter
add $a3, $a3, 12		# next slot on the openlist
j upCheck

upResume:
sw $a0, 0($a1)			# stores address of corresponding gameboard square to openlist
add $a1, $a1, 4
sub $t3, $t5, 1			# t3 has y coordinate of square added to openlist
add $t4, $t6, 0			# t4 has x coordinate of square added to openlist

add $t2, $s4, 0			# get location of player
div $t2, $t2, 4
div $t0, $t2, 10		# 
mul $t0, $t0, 10		# 
sub $t1, $t2, $t0		# t1 has x coordinate of playeer's square
div $t0, $t0, 10		# t0 has y coordinate of player's square 

sub $t3, $t3, $t0		# t3 = openY - playerY
sub $t4, $t4, $t1		# t4 = openX - playerX

bltz $t3, upResume1		# if t3 is negative
bltz $t4, upResume2		# if t4 is negative
j upResume3

upResume1:
mul $t3, $t3, -1		# negate t3
bltz $t4, upResume2		# if t4 is negative
j upResume3

upResume2:
mul $t4, $t4, -1		# negate t4
j upResume3

upResume3:
bgt $t3, $t4, upResume4		# branch if t3 is bigger than t4
sw $t4, 0($a1)			# set the second byte of open list item to huer value t4
j upResume5

upResume4:
sw $t3, 0($a1)			# set the second byte of open list item to huer value t3
j upResume5

upResume5:
add $a1, $a1, 4			# get address of parent slot in open list item
la $a0, currentSquare
lw $a0, 0($a0)
mul $a0, $a0, 4			
la $a2, gameboard
add $a0, $a0, $a2		# address of current square in GameBoard
sw $a0, 0($a1)			# store address of gameboard square in the parent slot

la $a0, openCount
lw $t0, 0($a0)
add $t0, $t0, 1
sw $t0, 0($a0)			# increment the number of items in openlist

la $a3, currentSquare
lw $t7, 0($a3)			# $t7 has the address of the computer's current square

li $s6, 10
div $t5, $t7, 10		# t5 = t7 / 10 = y coordinate of computer's square
mul $t5, $t5, 10		# temporarily make t5 = t5 * 10		
sub $t6, $t7, $t5		# t6 = t7 - t5 which gets the remainder (basically is t7 mod 10) which is the x coordinate
div $t5, $t5, 10		# t5 has y coordinate of computer's square 
j canDown



###########################################
# ADD SQUARE Below CURRENT LOCATION IF POSSIBLE
#	Check if it is in bounds 		(canUp)	
#	Check if it is open			(canUp)
#	Check if it has not already been added	(upCheck)
###########################################

canDown:
beq $t5, 9, canRight		#if the y coord is 9 check to see if you can move right
add $t4, $t7, 10		#t4 has the whole coord of the potentially open square

la $a0, gameboard		# a0 is starting address of gameboard array
mul $t4, $t4, 4			# t4 is offset
add $a0, $t4, $a0		# a0 is address in gameboard array for potential open square

lw $t4, 0($a0)			# t4 is now 0,1,2, or 3 for open, player, computer, or barrier

bnez $t4, canRight		# if it is not 0 or open then check down

la $a1, a_star1			# start of open list

la $a2, openCount
lw $t4, 0($a2)
add $t1, $t4, 0
mul $t4, $t4, 12		# open list items are 3 bytes wide

add $a1, $a1, $t4		#address of open list item

li $t0, 0
la $a3, a_star1

j downCheck

# if openlist contains this square skip the adding of it to the openlist
downCheck:
beq $t0, $t1, downResume		# t0 is counter t1 is # of items already in openlist 
lw $t3, 0($a3)
beq $t3, $a0, canRight		# This square is already in the openlist
add $t0, $t0, 1			# increment the counter
add $a3, $a3, 12		# next slot on the openlist
j downCheck

downResume:
sw $a0, 0($a1)			# stores address of corresponding gameboard square to openlist
add $a1, $a1, 4
add $t3, $t5, 1			# t3 has y coordinate of square added to openlist
add $t4, $t6, 0			# t4 has x coordinate of square added to openlist

add $t2, $s4, 0			# get location of player
div $t2, $t2, 4
div $t0, $t2, 10		# 
mul $t0, $t0, 10		# 
sub $t1, $t2, $t0		# t1 has x coordinate of playeer's square
div $t0, $t0, 10		# t0 has y coordinate of player's square 

sub $t3, $t3, $t0		# t3 = openY - playerY
sub $t4, $t4, $t1		# t4 = openX - playerX

bltz $t3, downResume1		# if t3 is negative
bltz $t4, downResume2		# if t4 is negative
j downResume3

downResume1:
mul $t3, $t3, -1		# negate t3
bltz $t4, downResume2		# if t4 is negative
j downResume3

downResume2:
mul $t4, $t4, -1		# negate t4
j downResume3

downResume3:
bgt $t3, $t4, downResume4		# branch if t3 is bigger than t4
sw $t4, 0($a1)			# set the second byte of open list item to huer value t4
j downResume5

downResume4:
sw $t3, 0($a1)			# set the second byte of open list item to huer value t3
j downResume5

downResume5:
add $a1, $a1, 4			# get address of parent slot in open list item
la $a0, currentSquare
lw $a0, 0($a0)
mul $a0, $a0, 4			
la $a2, gameboard
add $a0, $a0, $a2		# address of current square in GameBoard
sw $a0, 0($a1)			# store address of gameboard square in the parent slot

la $a0, openCount
lw $t0, 0($a0)
add $t0, $t0, 1
sw $t0, 0($a0)			# increment the number of items in openlist

la $a3, currentSquare
lw $t7, 0($a3)			# $t7 has the address of the computer's current square

li $s6, 10
div $t5, $t7, 10		# t5 = t7 / 10 = y coordinate of computer's square
mul $t5, $t5, 10		# temporarily make t5 = t5 * 10		
sub $t6, $t7, $t5		# t6 = t7 - t5 which gets the remainder (basically is t7 mod 10) which is the x coordinate
div $t5, $t5, 10		# t5 has y coordinate of computer's square 
j canRight




###########################################
# ADD SQUARE TO THE RIGHT OF CURRENT LOCATION IF POSSIBLE
#	Check if it is in bounds 		(canUp)	
#	Check if it is open			(canUp)
#	Check if it has not already been added	(upCheck)
###########################################

canRight:
beq $t6, 9, canLeft		#if the y coord is 0 check to see if you can move down
add $t4, $t7, 1			#t4 has the whole coord of the potentially open square

la $a0, gameboard		# a0 is starting address of gameboard array
mul $t4, $t4, 4			# t4 is offset
add $a0, $t4, $a0		# a0 is address in gameboard array for potential open square

lw $t4, 0($a0)			# t4 is now 0,1,2, or 3 for open, player, computer, or barrier

bnez $t4, canLeft		# if it is not 0 or open then check down

la $a1, a_star1			# start of open list

la $a2, openCount
lw $t4, 0($a2)
add $t1, $t4, 0
mul $t4, $t4, 12		# open list items are 3 bytes wide

add $a1, $a1, $t4		#address of open list item

li $t0, 0
la $a3, a_star1

j rightCheck

# if openlist contains this square skip the adding of it to the openlist
rightCheck:
beq $t0, $t1, rightResume	# t0 is counter t1 is # of items already in openlist 
lw $t3, 0($a3)
beq $t3, $a0, canLeft		# This square is already in the openlist
add $t0, $t0, 1			# increment the counter
add $a3, $a3, 12		# next slot on the openlist
j rightCheck

rightResume:
sw $a0, 0($a1)			# stores address of corresponding gameboard square to openlist
add $a1, $a1, 4
sub $t3, $t5, 0			# t3 has y coordinate of square added to openlist
add $t4, $t6, 1			# t4 has x coordinate of square added to openlist

add $t2, $s4, 0			# get location of player
div $t2, $t2, 4
div $t0, $t2, 10		# 
mul $t0, $t0, 10		# 
sub $t1, $t2, $t0		# t1 has x coordinate of playeer's square
div $t0, $t0, 10		# t0 has y coordinate of player's square 

sub $t3, $t3, $t0		# t3 = openY - playerY
sub $t4, $t4, $t1		# t4 = openX - playerX

bltz $t3, rightResume1		# if t3 is negative
bltz $t4, rightResume2		# if t4 is negative
j rightResume3

rightResume1:
mul $t3, $t3, -1		# negate t3
bltz $t4, rightResume2		# if t4 is negative
j rightResume3

rightResume2:
mul $t4, $t4, -1		# negate t4
j rightResume3

rightResume3:
bgt $t3, $t4, rightResume4	# branch if t3 is bigger than t4
sw $t4, 0($a1)			# set the second byte of open list item to huer value t4
j rightResume5

rightResume4:
sw $t3, 0($a1)			# set the second byte of open list item to huer value t3
j rightResume5

rightResume5:

add $a1, $a1, 4			# get address of parent slot in open list item
la $a0, currentSquare
lw $a0, 0($a0)
mul $a0, $a0, 4			
la $a2, gameboard
add $a0, $a0, $a2		# address of current square in GameBoard
sw $a0, 0($a1)			# store address of gameboard square in the parent slot

la $a0, openCount
lw $t0, 0($a0)
add $t0, $t0, 1
sw $t0, 0($a0)			# increment the number of items in openlist



la $a3, currentSquare
lw $t7, 0($a3)			# $t7 has the address of the computer's current square

li $s6, 10
div $t5, $t7, 10		# t5 = t7 / 10 = y coordinate of computer's square
mul $t5, $t5, 10		# temporarily make t5 = t5 * 10		
sub $t6, $t7, $t5		# t6 = t7 - t5 which gets the remainder (basically is t7 mod 10) which is the x coordinate
div $t5, $t5, 10		# t5 has y coordinate of computer's square 
j canLeft



###########################################
# ADD SQUARE TO THE LEFT OF CURRENT LOCATION IF POSSIBLE
#	Check if it is in bounds 		(canUp)	
#	Check if it is open			(canUp)
#	Check if it has not already been added	(upCheck)
###########################################

canLeft:
beq $t6, 0, extend		#if the y coord is 0 check to see if you can move down
sub $t4, $t7, 1			#t4 has the whole coord of the potentially open square

la $a0, gameboard		# a0 is starting address of gameboard array
mul $t4, $t4, 4			# t4 is offset
add $a0, $t4, $a0		# a0 is address in gameboard array for potential open square

lw $t4, 0($a0)			# t4 is now 0,1,2, or 3 for open, player, computer, or barrier

bnez $t4, extend		# if it is not 0 or open then check down

la $a1, a_star1			# start of open list

la $a2, openCount
lw $t4, 0($a2)
add $t1, $t4, 0
mul $t4, $t4, 12		# open list items are 3 bytes wide

add $a1, $a1, $t4		#address of open list item

li $t0, 0
la $a3, a_star1

j leftCheck

# if openlist contains this square skip the adding of it to the openlist
leftCheck:
beq $t0, $t1, leftResume		# t0 is counter t1 is # of items already in openlist 
lw $t3, 0($a3)
beq $t3, $a0, extend		# This square is already in the openlist
add $t0, $t0, 1			# increment the counter
add $a3, $a3, 12		# next slot on the openlist
j leftCheck

leftResume:
sw $a0, 0($a1)			# stores address of corresponding gameboard square to openlist
add $a1, $a1, 4
sub $t3, $t5, 0			# t3 has y coordinate of square added to openlist
sub $t4, $t6, 1			# t4 has x coordinate of square added to openlist

add $t2, $s4, 0			# get location of player
div $t2, $t2, 4
div $t0, $t2, 10		# 
mul $t0, $t0, 10		# 
sub $t1, $t2, $t0		# t1 has x coordinate of playeer's square
div $t0, $t0, 10		# t0 has y coordinate of player's square 

sub $t3, $t3, $t0		# t3 = openY - playerY
sub $t4, $t4, $t1		# t4 = openX - playerX

bltz $t3, leftResume1		# if t3 is negative
bltz $t4, leftResume2		# if t4 is negative
j leftResume3

leftResume1:
mul $t3, $t3, -1		# negate t3
bltz $t4, leftResume2		# if t4 is negative
j leftResume3

leftResume2:
mul $t4, $t4, -1		# negate t4
j leftResume3

leftResume3:
bgt $t3, $t4, leftResume4		# branch if t3 is bigger than t4
sw $t4, 0($a1)			# set the second byte of open list item to huer value t4
j leftResume5

leftResume4:
sw $t3, 0($a1)			# set the second byte of open list item to huer value t3
j leftResume5

leftResume5:
add $a1, $a1, 4			# get address of parent slot in open list item
la $a0, currentSquare
lw $a0, 0($a0)
mul $a0, $a0, 4			
la $a2, gameboard
add $a0, $a0, $a2		# address of current square in GameBoard
sw $a0, 0($a1)			# store address of gameboard square in the parent slot

la $a0, openCount
lw $t0, 0($a0)
add $t0, $t0, 1
sw $t0, 0($a0)			# increment the number of items in openlist

la $a3, currentSquare
lw $t7, 0($a3)			# $t7 has the address of the computer's current square

li $s6, 10
div $t5, $t7, 10		# t5 = t7 / 10 = y coordinate of computer's square
mul $t5, $t5, 10		# temporarily make t5 = t5 * 10		
sub $t6, $t7, $t5		# t6 = t7 - t5 which gets the remainder (basically is t7 mod 10) which is the x coordinate
div $t5, $t5, 10		# t5 has y coordinate of computer's square 
j extend

###############################
#THIS EXTENDS SQUARES
###############################

extend:
la $a0, a_star1			# start address for open list
la $a1, openCount		# adress for count of open items
lw $t0, 0($a1)			# count of open list items
li $t1, 0			# iterator
li $t2, 249			# min value
j extend1

extend1:
beq $t0, $t1, extend3		# check iterator
mul $t7, $t1, 12		# go to open list item
add $t7, $t7, 4			# go to huer of open list item
add $a2, $a0, $t7		# set address
lw $t3, 0($a2)			# get huer of that open list item
add $t1, $t1, 1			# increment iterator
blt $t3, $t2, extend2		# if this is the new lowest huer value
j extend1

extend2:
add $t2, $t3, 0			# set new lowest huer		
sub $t4, $t1, 1			# index of winning square
j extend1

#actually extend it
extend3:

#set huer to 250 so as to indicate that it is closed
mul $t7, $t4, 12		# go to open list item
add $t7, $t7, 4			# go to huer of open list item
add $a2, $a0, $t7		# set address

li $t7, 250
sw $t7, 0($a2)			# set open list item huer to 250

add $a2, $a2, 4			# get address of parent slot

la $a3, currentSquare		# address of currentSquare
#THIS WAS ERRONEOUSLY PLACED HERE
lw $t7, 0($a3)			# this gives me the coord of currentSquare

la $a3, a_star1


#sw $a3, 0($a2)			# stores parent of openlist item

############################
# The parent of the open list item is an address of a gameboard item
# much like the addr part is
# so the openitem with the addr that is the same as another ones parent are related
############################

# TESTING BREAKPOINT
#li $v0, 5
#syscall

sub $a2, $a2, 8
lw $t7, 0($a2)			# load the addr of newly extended item	
la $a3, gameboard
sub $t7, $t7, $a3
div $t7, $t7, 4		# convert to coordinate
la $a3, currentSquare
sw  $t7, 0($a3)			# set current square

# TESTING BREAKPOINT
#li $v0, 5
#syscall

#CHECK IF PATH COMPLETE

div $t0, $s4, 4

add $t6, $t7, 1
beq $t6, $t0, pathFound
add $t6, $t7, 10
beq $t6, $t0, pathFound
sub $t6, $t7, 1
beq $t6, $t0, pathFound
sub $t6, $t7, 10
beq $t6, $t0, pathFound

j findOpen

pathFound:
la $a0, pathfound
li $v0, 4
syscall


#a2 still has the address of the last extended item
add $t0, $s5, 0
la $a3, gameboard
#mul $t0, $t0, 4
add $a3, $a3, $t0		# address of the player's position 
				# so this should equal the parent of 
				# the next square that the computer should go to

j findNext

findNext:

#a2 still has the address of the last extended item
add $a2, $a2, 8
lw $t7, 0($a2)			# t7 is the parent of the open list item
beq $t7, $a3, compMove		# is t7 equal to the computer's position?

la $a0, a_star1			# get address of start of list

j findNext1

findNext1:
lw $t0, 0($a0)
beq $t7, $t0, findNext2
add $a0, $a0, 12
j findNext1

findNext2:
add $a2, $a0, 0
j findNext

compMove:
sub $a2, $a2, 8
lw $s6, 0($a2)
la $a3, gameboard
sub $s6, $s6, $a3
div $s6, $s6, 4			# coordinate of computer after move
#MOVE COMPUTER HERE
j place_computer


game_over:
la $a0, print_game_over
li $v0, 4
syscall
