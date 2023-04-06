#check what thing you need to add for 512 x 256
.data



.eqv	SHIFT_GHOST_LAST    1324
.eqv	DISPLAY_LAST_ADDRESS	0x10009FFC					# update this given the values below shift +(64*32-1)*4
.eqv	DISPLAY_MIDLFT_ADDRESS	0x10008C10					# mid left spot for ship (but jump 2 aligned) +(64*12+4)*4
.eqv	DISPLAY_SCORE		0x10009AF0					# bottom right corner +(64*27-4)*4
.eqv	DISPLAY_LIVES		0x100081E8					# top right corner +(64*2-6)*4
.eqv	DISPLAY_DEAD		0x10008C58					# top right corner +(64*13-42)*4
.eqv	DISPLAY_SPLASH		0x10008C14					# top right corner +(64*13-59)*4
# last address shifts
.eqv	SHIFT_NEXT_ROW		256						# next row shift = width*4 = 64*4
.eqv	SHIFT_SHIP_LAST		1324						# from top left of ship to bottom right = (64*5+11)*4
.eqv	SHIFT_ROCK_LAST		1564						# from top left of rock to bottom right = (64*6+7)*4

#ghost
.eqv 	COLOUR_BLACK 0x000000
.eqv 	COLOUR_WHITE 0xFFFFFF
.eqv 	COLOUR_PURPLE 0xC433C4

#fire
.eqv    COLOUR_ORANGE 0xFF8000
.eqv    COLOUR_RED 0xFF0000

.eqv    COLOUR_DARKBLUE 0x0C0A31
.eqv 	COLOUR_YELLOW 0xFFC20E

.eqv    COLOUR_LIGHTBLUE 0xADD8E6

.eqv FIRE_ROW_WIDTH 32   # Number of bytes in each row of a fire
.eqv FIRE_WIDTH 8        # Number of pixels in each fire
.eqv FIRE_NEXT_ROW 128   # Number of bytes to shift to next row of a fire (4 bytes per pixel * 32 pixels per row)

.eqv GHOST_WIDTH 9
.eqv GHOST_HEIGHT 7
.eqv	DISPLAY_LAST_ADDRESS	0x10009FFC		

.eqv BASELINEADRESS 0x10008000	#256 wide x 256 high pixels
.eqv LOAD 0x40000  #saves 256 x 256 pixels
.eqv OG_GHOST_POSITION 0x10009804 
   
.eqv CURRENT_GHOST_ADDRESS 0x10009FFC	

.eqv FIRE_POSITION  0x1000BA00   # 0x1000BA00 #0x1000B900		




.text
main:
## clear the display in yellow
la $t0, BASELINEADRESS	# load frame buffer addres
li $t1, LOAD # save 256x256
li $t2, 0xFF0000	# load red color
jal normal_colour

li $t2, COLOUR_DARKBLUE	# load light blue color
la $t0, BASELINEADRESS	# load frame buffer addres
li $t1, LOAD # save 512*256 pixels


jal normal_colour



li	$s1, OG_GHOST_POSITION #0x10008804

move	$a0, $s1

jal	draw_ghost


#drawing fire

li	$s2, FIRE_POSITION #0x10008804
move $a0, $s2

li      $t6, 0
jal draw_fires

#draw stripes
#li $t2, 0xFF0000	# load red color
#la $t0, BASELINEADRESS	# load frame buffer address
#li $t1, 0x20000 # save 512*256 pixels

#jal stripe_colour





main_loop:
	li $t9, 0xffff0000
	lw $t8, 0($t9)
	move $a0, $s1
	beq $t8, 1, keypress_happened
	#move $s1, $a0
	
	move $s1, $a0
	
	jal draw_ghost
	
	
	j main_loop
	


clear:
	
	li 	$t4, 10
	j erase_old_position_loop
	jr $ra

	


keypress_happened:
	# wait 2000 milliseconds
	li	$t1, SHIFT_NEXT_ROW
	addi 	$t1, $t1, 12
	li	$t2, BASELINEADRESS
	addi	$t2, $t2, SHIFT_NEXT_ROW
	
	li $t3, 0x0000000
	
	lw $t0, 4($t9)
	beq	$t0, 0x61, key_a						# ASCII code of 'a' is 0x61 or 97 in decimal
	beq	$t0, 0x77, key_w	 					# ASCII code of 'w' is 0x77
	beq	$t0, 0x64, key_d						# ASCII code of 'd' is 0x64
	beq	$t0, 0x73, key_s						# ASCII code of 's' is 0x73
	
	
	
key_a:
		# make sure ship is not in left column
		div	$s1, $t1						# see if ship position is divisible by the width
		mfhi	$t9							# $t9 = $s1 mod $t1 
		beq	$t9, $zero, keypress_done				# if it is in the left column, we can't go left
		addi	$s1, $s1, -8						# else, move left
		j main_loop

	# go up
key_w:
		# make sure ship is not in top row
		blt	$s1, $t2, keypress_done					# if $s1 is in the top row, don't go up
		addi	$s1, $s1, -SHIFT_NEXT_ROW				# else, move up
		addi	$s1, $s1, -SHIFT_NEXT_ROW				# else, move up
		j main_loop

	# go right
key_d:
		# make sure ship is not in right column
		div	$s1, $t1						# see if ship position is divisible by the width
		mfhi	$t9							# $t9 = $s1 mod $t1 
		addi	$t1, $t1, -48						# need to check if the mod is the row size - 12*4 (width of plane-1)
		beq	$t9, $t1, keypress_done					# if it is in the far right column, we can't go right
		addi	$s1, $s1, 8						# else, move right
		j main_loop

	# go down
key_s:
		# make sure ship is not in bottom row
		#bgt	$s1, $t3, keypress_done					# if $s1 is in the bottom row, don't go down
		addi	$s1, $s1, SHIFT_NEXT_ROW				# else, move down
		addi	$s1, $s1, SHIFT_NEXT_ROW				# else, move down
		j main_loop




keypress_done:
	jr $ra

draw_platform:
#random number between 5 and 10
	li $t0 COLOUR_YELLOW
	sw	$t0, 8($a0)
	sw	$t1, 12($a0)
	sw	$t2, 16($a0)
	sw	$t0, 20($a0)
	sw	$t2, 24($a0)
	sw	$t2, 28($a0)
	


draw_fires:
  beq $t6, 8, print_fires_exit  # Print 10 fires, then exit

  # Draw fire at current position
  li	$t0, COLOUR_RED					
li	$t1, COLOUR_WHITE						
li	$t2, COLOUR_YELLOW
li      $t3, COLOUR_ORANGE
	sw	$t1, 12($a0)
	
	addi	$a0, $a0, SHIFT_NEXT_ROW

	sw	$t3, 12($a0)
	sw	$t2, 16($a0)
	sw	$t0, 24($a0)
	
	addi	$a0, $a0, SHIFT_NEXT_ROW

	sw	$t0, 8($a0)
	sw	$t1, 12($a0)
	sw	$t2, 16($a0)
	sw	$t0, 20($a0)
	sw	$t2, 24($a0)
	sw	$t2, 28($a0)


	addi	$a0, $a0, SHIFT_NEXT_ROW


	sw	$t2, 4($a0)
	sw	$t3, 8($a0)
	sw	$t2, 12($a0)
	sw	$t0, 16($a0)
	sw	$t3, 20($a0)
	sw	$t1, 24($a0)
	sw	$t3, 28($a0)

	
	addi	$a0, $a0, SHIFT_NEXT_ROW

	sw	$t2, 4($a0)
	sw	$t0, 8($a0)
	sw	$t3, 12($a0)
	sw	$t3, 16($a0)
	sw	$t0, 20($a0)
	sw	$t3, 24($a0)
	sw	$t1, 28($a0)
	
	addi	$a0, $a0, SHIFT_NEXT_ROW
	sw	$t0, 0($a0)
	sw	$t3, 4($a0)
	sw	$t3, 8($a0)
	sw	$t0, 12($a0)
	sw	$t0, 16($a0)
	sw	$t2, 20($a0)
	sw	$t3, 24($a0)
	sw	$t2, 28($a0)
  
  
  # Move to next position
  addi $t6, $t6, 1
  addiu $s2, $s2, 32
  move	$a0, $s2

  j draw_fires
  

print_fires_exit:
  # Exit the subroutine
  jr $ra

normal_colour:
sw $t2, 0($t0)
addi $t0, $t0, 4 # advance to next pixel position in display

addi $t1, $t1, -1	# decrement number of pixels
bnez $t1, normal_colour # repeat while number of pixels is not zero
jr $ra

stripe_colour:
sw $t2, 0($t0)
addi $t0, $t0, 8 # advance to next pixel position in display

addi $t1, $t1, -1	# decrement number of pixels
bnez $t1, stripe_colour # repeat while number of pixels is not zero
jr $ra

draw_ghost:
	
	li	$t0, COLOUR_PURPLE					
	li	$t1, COLOUR_WHITE						
	li	$t2, COLOUR_BLACK						
	

	sw	$t2, 16($a0)
	sw	$t2, 20($a0)
	sw	$t2, 24($a0)
	sw	$t2, 28($a0)
	
	addi	$a0, $a0, SHIFT_NEXT_ROW

	sw	$t2, 12($a0)
	sw	$t1, 16($a0)
	sw	$t1, 20($a0)
	sw	$t1, 24($a0)
	sw	$t1, 28($a0)
	sw	$t2, 32($a0)
	
	addi	$a0, $a0, SHIFT_NEXT_ROW

	sw	$t2, 12($a0)
	sw	$t1, 16($a0)
	sw	$t1, 20($a0)
	sw	$t1, 24($a0)
	sw	$t1, 28($a0)
	sw	$t1, 32($a0)
	sw	$t2, 36($a0)
	
	addi	$a0, $a0, SHIFT_NEXT_ROW

	sw	$t2, 12($a0)
	sw	$t1, 16($a0)
	sw	$t1, 20($a0)
	sw	$t2, 24($a0)
	sw	$t1, 28($a0)
	sw	$t2, 32($a0)
	sw	$t1, 36($a0)
	sw	$t2, 40($a0)	
	
	addi	$a0, $a0, SHIFT_NEXT_ROW

	sw	$t2, 12($a0)
	sw	$t1, 16($a0)
	sw	$t1, 20($a0)
	sw	$t2, 24($a0)
	sw	$t1, 28($a0)
	sw	$t2, 32($a0)
	sw	$t1, 36($a0)
	sw	$t2, 40($a0)
	
	addi	$a0, $a0, SHIFT_NEXT_ROW

	sw	$t2, 8($a0)
	sw	$t1, 12($a0)
	sw	$t1, 16($a0)
	sw	$t0, 20($a0)
	sw	$t1, 24($a0)
	sw	$t1, 28($a0)
	sw	$t1, 32($a0)
	sw	$t0, 36($a0)
	sw	$t2, 40($a0)
	
	addi	$a0, $a0, SHIFT_NEXT_ROW

	sw	$t2, 8($a0)
	sw	$t1, 12($a0)
	sw	$t1, 16($a0)
	sw	$t1, 20($a0)
	sw	$t1, 24($a0)
	sw	$t1, 28($a0)
	sw	$t1, 32($a0)
	sw	$t1, 36($a0)
	sw	$t2, 40($a0)
	
	addi	$a0, $a0, SHIFT_NEXT_ROW

	sw	$t2, 4($a0)
	sw	$t1, 8($a0)
	sw	$t1, 12($a0)
	sw	$t1, 16($a0)
	sw	$t1, 20($a0)
	sw	$t1, 24($a0)
	sw	$t1, 28($a0)
	sw	$t1, 32($a0)
	sw	$t1, 36($a0)
	sw	$t1, 40($a0)
	sw	$t2, 44($a0)
	
	addi	$a0, $a0, SHIFT_NEXT_ROW

	sw	$t2, 4($a0)
	sw	$t1, 8($a0)
	sw	$t1, 12($a0)
	sw	$t1, 16($a0)
	sw	$t1, 20($a0)
	sw	$t2, 24($a0)
	sw	$t1, 28($a0)
	sw	$t1, 32($a0)
	sw	$t1, 36($a0)
	sw	$t1, 40($a0)
	sw	$t2, 44($a0)
	
	addi	$a0, $a0, SHIFT_NEXT_ROW

	sw	$t2, 4($a0)
	sw	$t2, 8($a0)
	sw	$t1, 12($a0)
	sw	$t1, 16($a0)
	sw	$t2, 20($a0)
	sw	$t2, 28($a0)
	sw	$t1, 32($a0)
	sw	$t1, 36($a0)
	sw	$t2, 40($a0)
	
	addi	$a0, $a0, SHIFT_NEXT_ROW


	sw	$t2, 12($a0)
	sw	$t2, 16($a0)
	sw	$t2, 32($a0)
	sw	$t2, 36($a0)
	
	jr	$ra	



# GLOBAL variables
		# $s0: previous ghost location
		# $s1: ghost location
		# $s2: fire
		# $s3: 1 if collision happened, 0 if not
		# $s4: clock (number of frames played)
		# $s5: 
		# $s6: wait time (decreases as time goes on)
		# $s7: wait clock


erase_old_position_loop:
	li	$t5, COLOUR_DARKBLUE
	
	sw	$t5, 0($a0)		# Set the pixel to black
	sw	$t5, 4($a0)
	sw	$t5, 8($a0)
	sw	$t5, 12($a0)
	sw	$t5, 16($a0)
	sw	$t5, 20($a0)
	sw	$t5, 24($a0)
	sw	$t5, 28($a0)
	sw	$t5, 32($a0)
	sw	$t5, 36($a0)
	sw	$t5, 40($a0)
	sw	$t5, 44($a0)
	
	addi	$a0, $a0, SHIFT_NEXT_ROW
	addi	$t4, $t4, -1		# Decrement the pixel count
	bne	$t4, $zero, erase_old_position_loop	# If we haven't erased all pixels, loop again
	
#li	$v0, 32
#li	$a0, 4000
#syscall

j erase_done


erase_done:
	jr $ra

	







exit:
li $v0, 10	# exit the program
syscall



