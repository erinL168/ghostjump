#####################################################################
#
# CSCB58 Winter 2023 Assembly Final Project
# University of Toronto, Scarborough
#

#
# Bitmap Display Configuration:
# - Unit width in pixels: 4
# - Unit height in pixels: 4
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
#
# Which milestones have been reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 3 (choose the one the applies)
#
# Which approved features have been implemented for milestone 3?
# (See the assignment handout for the list of additional features)
# 1. Health [2]
# 2. Fail Screen [1]
# 4. Double Jump [1]
# 5. Moving platformss[2]
# 6. Dissapearing Platforms(reappear and dissapear)[2]
# ... (add more if necessary)
#
# Link to video demonstration for final submission:
# - https://www.loom.com/share/fd2320474f7b49959d4c8d7103060ce8
#
# Are you OK with us sharing the video with people outside course staff?
# - yes, and please share this project github link as well!
#
# Any additional information that the TA needs to know:
# - (write here, if any)
#
#####################################################################
# Bitmap display starter code
#
# Bitmap Display Configuration:
# - Unit width in pixels: 4
# - Unit height in pixels: 4
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
#check what thing you need to add for 512 x 256


# last address shifts
.eqv	SHIFT_NEXT_ROW		256						# next row shift = width*4 = 64*4

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

.eqv GHOST_MID 24
.eqv GHOST_HEIGHT 2560


.eqv BASE_ADDRESS 0x10008000	#256 wide x 256 high pixels
.eqv LOAD 0x40000  #saves 256 x 256 pixels
.eqv OG_GHOST_POSITION 0x10009804 
   
.eqv CURRENT_GHOST_ADDRESS 0x10009FFC	

.eqv FIRE_POSITION  0x1000BA00   # 0x1000BA00 #0x1000B900		

.eqv CLOCK 50
.eqv ON_PLATFORM 1
.eqv doublejump 2

.eqv PLATFORM_CLOCK 6000
.eqv	COLOUR_HEART 0x00fb91b3
.eqv HEART_ADDRESS 0x100081E0

.data
#pf:	.space			25					# array of 25 address for all the platform locations

platform: .word 0 0 0 0 0 0#three platforms
health: .word 0
eq: .asciiz "Below is yellow \n"


.text
main:
	
	li $t0, BASE_ADDRESS	# load frame buffer addres
	li $t1, LOAD # save 256x256

	li $t2, COLOUR_LIGHTBLUE	# load light blue color

	jal clear
	

	

#draw ghost
	li $v0, 32
	li $a0, 1000
	syscall
	

	move $s0, $t0
	move $s1, $t0
	move	$a0, $s1
	jal	draw_ghost




#draw platform
	li $a3, BASE_ADDRESS
	jal draw_platforms_A
	jal draw_platforms_B
	
	
	
#draw heart
	li $t7, HEART_ADDRESS
	move $a0, $t7
	jal draw_heart

	
	
#draw fire
	li	$s2, FIRE_POSITION #0x10008804
	#addi $t3, $s2, 
	sw $t2, 0($s2)
	
	move	$a0, $s2
	li      $s0, 0
	jal draw_fires
	
	
	
	

	move $s0, $s1

	li $t8, CLOCK
	move $s4, $t8
	
	li $t9, PLATFORM_CLOCK
	move $s5, $t9


	#li $s2, 1 #health, set to 0 after falling into pit once
	la $t2, health
	li $t3, 1
	sw $t3, 0($t2)
	
	

	j main_loop

second_life:

	li $t0, BASE_ADDRESS	# load frame buffer addres
	li $t1, LOAD # save 256x256

	li $t2, COLOUR_LIGHTBLUE	# load light blue color

	jal clear
	

	

#draw ghost
	li $v0, 32
	li $a0, 1000
	syscall
	

	move $s0, $t0
	move $s1, $t0
	move	$a0, $s1
	jal	draw_ghost




#draw platform
	li $a3, BASE_ADDRESS
	jal draw_platforms_A
	jal draw_platforms_B
	
	

	
#draw fire
	li	$s2, FIRE_POSITION #0x10008804
	#addi $t3, $s2, 
	sw $t2, 0($s2)
	
	move	$a0, $s2
	li      $s0, 0
	jal draw_fires
	
	
	
	

	move $s0, $s1

	li $t8, CLOCK
	move $s4, $t8
	
	li $t9, PLATFORM_CLOCK
	move $s5, $t9


	la $t2, health
	li $t3, 0
	sw $t3, 0($t2)
	

	j main_loop

	
draw_platforms_A:
	move $s6, $ra
	la $a2, platform
	#li $t3, BASE_ADDRESS
	move $t3, $a3

	addi $t3, $t3, 2816 #platform one 
	#platform 1
	sw $t3, 0($a2)
	lw $a0, 0($a2)
	jal draw_platform

	addi $t3, $t3, 40
	addi $t3, $t3, 2816
	sw $t3, 4($a2)
	lw $a0, 4($a2)
	jal draw_platform
	
	addi $t3, $t3, 40
	addi $t3, $t3, 2816
	sw $t3, 8($a2)
	lw $a0, 8($a2)
	jal draw_platform
	jr $s6
	
	
draw_platforms_B:
	move $s6, $ra
	la $a2, platform
	li $t3, BASE_ADDRESS
	#move $t3, $a3

	addi $t3, $t3, 11264 #platform one 
	#platform 1
	sw $t3, 12($a2)
	lw $a0, 12($a2)
	jal draw_platform

	addi $t3, $t3, 80
	addi $t3, $t3, 2560
	sw $t3, 16($a2)
	lw $a0, 16($a2)
	jal draw_platform
	
	addi $t3, $t3, 80
	addi $t3, $t3, -7680 
	sw $t3, 20($a2)
	lw $a0, 20($a2)
	jal draw_platform
	jr $s6
		
		
erase_platforms_A:
	move $s6, $ra
	la $a2, platform
	#li $t3, BASE_ADDRESS
	move $t3, $a3

	addi $t3, $t3, 2816 #platform one 
	#platform 1
	sw $t3, 0($a2)
	lw $a0, 0($a2)
	jal erase_platform

	addi $t3, $t3, 40
	addi $t3, $t3, 2816
	sw $t3, 4($a2)
	lw $a0, 4($a2)
	jal erase_platform
	
	addi $t3, $t3, 40
	addi $t3, $t3, 2816
	sw $t3, 8($a2)
	lw $a0, 8($a2)
	jal erase_platform
	jr $s6
	
	
erase_platforms_B:
	move $s6, $ra
	la $a2, platform
	li $t3, BASE_ADDRESS
	#move $t3, $a3


	addi $t3, $t3, 11264 #platform one 
	#platform 1
	sw $t3, 12($a2)
	lw $a0, 12($a2)
	jal erase_platform

	addi $t3, $t3, 80
	addi $t3, $t3, 2560
	sw $t3, 16($a2)
	lw $a0, 16($a2)
	jal erase_platform
	
	addi $t3, $t3, 80
	addi $t3, $t3, -7680 
	sw $t3, 20($a2)
	lw $a0, 20($a2)
	jal erase_platform
	jr $s6		

main_loop:
	#a2: platform array
	#a3: platform A base address

	#s0: old ghost position 
	#s1: new position for ghost or current
	#s2: health
	#s3: 1 if on platform, 0 is not
	#s4: clock
	#s5: platform clock
	#s6: old callee
	#s7: remainder
	
	li $t9, 0xffff0000
	lw $t8, 0($t9)
	
	jal check_platform 
	
	#la $s2, health
	#lw $t4, 0($s2)
	
	
	
	bne $t8, 1, update
	jal keypress_happened
	
	update:
		
	
		beq $s3, 1, move_platforms
		addi $s5, $s5, -1
		bne $s5, $zero, continue
		li $s5, PLATFORM_CLOCK
		continue:
		
		add $s4, $s4, -1
		bne $s4, $zero, move_platforms
	
			gravity:
				move $a0, $s0
				jal erase_ghost
				addi $s1, $s1, SHIFT_NEXT_ROW
				move $a0, $s1
				jal draw_ghost		
				move $s0, $s1
				li $s4, CLOCK
			#platforms move back and forth
			
	move_platforms:
		
		#addi $a3, $a3, 40
		
		#jal draw_platforms_A
		jal draw_platforms_B
		
		bgt $s5, 3000, skip
			
			#jal draw_platforms_B
			jal erase_platforms_B
			#fire moves left
			
			
			#move platform
			li $t3, 500
			div $s5, $t3
			mfhi $s7
		
			bne $s7, $zero, go_home
			jal erase_platforms_A
			addi $a3, $a3, -4
			jal draw_platforms_A
			j go_home
			
			
		skip:
			
			#li $a3, BASE_ADDRESS
			#jal draw_platforms_A
			#jal draw_platforms_B
			#jal erase_platforms_B
			
			#move platform
			li $t3, 500
			div $s5, $t3
			mfhi $s7
		
			bne $s7, $zero, go_home
			jal erase_platforms_A
			addi $a3, $a3, 4
			jal draw_platforms_A
		
	go_home:
	
	jal fire_collision
	j main_loop
	



fire_collision:
	move $s6, $ra
	li $t3, FIRE_POSITION
	addi $t3, $t3, -2816
	
	la $t4, health
	lw $t5, 0($t4)

	
	bge	$s1, $t3, check_hearts					# if $s1 is in the bottom row, don't g
	j go_back_hearts
	check_hearts:
		beq $t5, 1, play_again
		
		j game_over
	play_again:
		li $t8, 0
		lw $t8, 0($t4)
		li $t7, HEART_ADDRESS
		move $a0, $t7
		jal erase_heart
		j second_life
		
	
		
	go_back_hearts:
	jr $s6
	
keypress_happened:
	# wait 2000 milliseconds
	move $s6, $ra
	
	li	$t1, SHIFT_NEXT_ROW
	addi 	$t1, $t1, 12
	li	$t2, BASE_ADDRESS
	addi	$t2, $t2, SHIFT_NEXT_ROW
	
	#li $t3, 0x0000000
	
	lw $t0, 4($t9)
	beq	$t0, 0x61, key_a						# ASCII code of 'a' is 0x61 or 97 in decimal
	beq	$t0, 0x77, key_w	 					# ASCII code of 'w' is 0x77
	beq	$t0, 0x64, key_d						# ASCII code of 'd' is 0x64
	beq	$t0, 0x73, key_s						# ASCII code of 's' is 0x73
	beq	$t0, 0x70, key_p
	b key_done
	
key_a:
	
	move $a0, $s1

	beq $v0, 0, key_done
	
	move $a0, $s1
	move $s0, $s1
	jal erase_ghost
  	addi $s1, $s1, -8
  	move $a0, $s1
	jal draw_ghost
  	b key_done

	# go up
key_w:
		# make sure ghost is not in top row
		blt	$s1, $t2, key_done					# if $s1 is in the top row, don't go up
		move $a0, $s1
		move $s0, $s1
		jal erase_ghost
		addi	$s1, $s1, -SHIFT_NEXT_ROW				# else, move up
		addi	$s1, $s1, -SHIFT_NEXT_ROW				# else, move up
		addi	$s1, $s1, -SHIFT_NEXT_ROW				# else, move up
		addi	$s1, $s1, -SHIFT_NEXT_ROW				# else, move up
		addi	$s1, $s1, -SHIFT_NEXT_ROW				# else, move up
		addi	$s1, $s1, -SHIFT_NEXT_ROW				# else, move up
		addi	$s1, $s1, -SHIFT_NEXT_ROW				# else, move up
		addi	$s1, $s1, -SHIFT_NEXT_ROW				# else, move up
		move $a0, $s1
		jal draw_ghost
		b key_done

	# go right
key_d:
		# make sure ghost is not in right column
		li	$t1, SHIFT_NEXT_ROW
		addi $t1, $t1, 8
		div	$s1, $t1						# see if ship position is divisible by the width
		mfhi	$t9							# $t9 = $s1 mod $t1 
		addi	$t1, $t1, -48						# need to check if the mod is the row size - 12*4 (width of plane-1)
		beq	$t9, $t1, key_done					# if it is in the far right column, we can't go right
		move $a0, $s1
		move $s0, $s1
		jal erase_ghost
		addi	$s1, $s1, 8						# else, move right
		move $a0, $s1
		jal draw_ghost
		b key_done

	# go down
key_s:
		# make sure ghost is not in bottom row
		#bgt	$s1, , key_done					# if $s1 is in the bottom row, don't go down
		beq $s3, 1, key_done
		move $a0, $s1
		move $s0, $s1
		jal erase_ghost
		addi	$s1, $s1, SHIFT_NEXT_ROW				# else, move down
		addi	$s1, $s1, SHIFT_NEXT_ROW				# else, move down
		move $a0, $s1
		jal draw_ghost
		b key_done


key_p:
		# restart game
		
		la	$s6, main
		b key_done

key_done:
	#j main_loop
	jr $s6
	#jr $ra


check_platform:
			
	#t1 colour

	#t4 bottom right
	#t5 bottom left)
	
	#t6: bottom right colour one row below
	#t7: bottom left colour one row below
	li $t5, 0
	li $t4, 0
	addi $t5, $s1, 2560 #bototm left
	
	addi $t4, $t5, 40 #bottom right
	
	li $t7, 0 #initiating t7 so that it stores the colour below the bottom right corner ghost pixel
	addi $t7, $t5, SHIFT_NEXT_ROW #t6 stores the location of the pixel one row underneath
	lw $t7, 0($t7) #gets colour and stores in t7
	
	li $t6, 0 #initiating t7 so that it stores the colour below the bottom right corner ghost pixel
	addi $t6, $t4, SHIFT_NEXT_ROW #t6 stores the location of the pixel one row underneath
	lw $t6, 0($t6) #gets colour and stores in t7

   	li $t1, COLOUR_YELLOW

   
   	beq $t7, $t1, below_plat #it below is a platform
   	beq $t6, $t1, below_plat
   	
   	li $s3, 0
   	jr $ra
   	
below_plat:
  	li $s3, 1
	jr $ra

draw_heart:
	li	$t9, COLOUR_HEART
	
	sw	$t9, 0($a0)
	sw	$t9, 4($a0)
	sw	$t9, 12($a0)
	sw	$t9, 16($a0)
	addi	$a0, $a0, SHIFT_NEXT_ROW
	sw	$t9, 0($a0)
	sw	$t9, 4($a0)
	sw	$t9, 8($a0)
	sw	$t9, 12($a0)
	sw	$t9, 16($a0)
	addi	$a0, $a0, SHIFT_NEXT_ROW
	sw	$t9, 4($a0)
	sw	$t9, 8($a0)
	sw	$t9, 12($a0)	
	addi	$a0, $a0, SHIFT_NEXT_ROW
	sw	$t9, 8($a0)
	
	jr $ra
	
	
erase_heart:
	li	$t9, COLOUR_BLACK
	
	sw	$t9, 0($a0)
	sw	$t9, 4($a0)
	sw	$t9, 12($a0)
	sw	$t9, 16($a0)
	addi	$a0, $a0, SHIFT_NEXT_ROW
	sw	$t9, 0($a0)
	sw	$t9, 4($a0)
	sw	$t9, 8($a0)
	sw	$t9, 12($a0)
	sw	$t9, 16($a0)
	addi	$a0, $a0, SHIFT_NEXT_ROW
	sw	$t9, 4($a0)
	sw	$t9, 8($a0)
	sw	$t9, 12($a0)	
	addi	$a0, $a0, SHIFT_NEXT_ROW
	sw	$t9, 8($a0)
	
	jr $ra

draw_platform:
	li $t2, COLOUR_YELLOW
	
	sw	$t2, 0($a0)
	sw	$t2, 4($a0)
	sw	$t2, 8($a0)
	sw	$t2, 12($a0)
	sw	$t2, 16($a0)
	sw	$t2, 20($a0)
	sw	$t2, 24($a0)
	sw	$t2, 28($a0)
	sw	$t2, 32($a0)
	sw	$t2, 36($a0)
	sw	$t2, 40($a0)
	sw	$t2, 44($a0)
	sw	$t2, 48($a0)
	jr 	$ra
	

erase_platform:
	li $t2, COLOUR_BLACK
	
	sw	$t2, 0($a0)
	sw	$t2, 4($a0)
	sw	$t2, 8($a0)
	sw	$t2, 12($a0)
	sw	$t2, 16($a0)
	sw	$t2, 20($a0)
	sw	$t2, 24($a0)
	sw	$t2, 28($a0)
	sw	$t2, 32($a0)
	sw	$t2, 36($a0)
	sw	$t2, 40($a0)
	sw	$t2, 44($a0)
	sw	$t2, 48($a0)
	jr 	$ra

draw_ghost:
	
	li	$t0, COLOUR_PURPLE					
	li	$t1, COLOUR_WHITE						
	li	$t2, COLOUR_BLACK						
	

	sw	$t2, 12($a0)
	sw	$t2, 16($a0)
	sw	$t2, 20($a0)
	sw	$t2, 24($a0)
	
	addi	$a0, $a0, SHIFT_NEXT_ROW

	sw	$t2, 8($a0)
	sw	$t1, 12($a0)
	sw	$t1, 16($a0)
	sw	$t1, 20($a0)
	sw	$t1, 24($a0)
	sw	$t2, 28($a0)
	
	addi	$a0, $a0, SHIFT_NEXT_ROW

	sw	$t2, 8($a0)
	sw	$t1, 12($a0)
	sw	$t1, 16($a0)
	sw	$t1, 20($a0)
	sw	$t1, 24($a0)
	sw	$t1, 28($a0)
	sw	$t2, 32($a0)
	
	addi	$a0, $a0, SHIFT_NEXT_ROW

	sw	$t2, 8($a0)
	sw	$t1, 12($a0)
	sw	$t1, 16($a0)
	sw	$t2, 20($a0)
	sw	$t1, 24($a0)
	sw	$t2, 28($a0)
	sw	$t1, 32($a0)
	sw	$t2, 36($a0)	
	
	addi	$a0, $a0, SHIFT_NEXT_ROW

	sw	$t2, 8($a0)
	sw	$t1, 12($a0)
	sw	$t1, 16($a0)
	sw	$t2, 20($a0)
	sw	$t1, 24($a0)
	sw	$t2, 28($a0)
	sw	$t1, 32($a0)
	sw	$t2, 36($a0)
	
	addi	$a0, $a0, SHIFT_NEXT_ROW

	sw	$t2, 4($a0)
	sw	$t1, 8($a0)
	sw	$t1, 12($a0)
	sw	$t0, 16($a0)
	sw	$t1, 20($a0)
	sw	$t1, 24($a0)
	sw	$t1, 28($a0)
	sw	$t0, 32($a0)
	sw	$t2, 36($a0)
	
	addi	$a0, $a0, SHIFT_NEXT_ROW

	sw	$t2, 4($a0)
	sw	$t1, 8($a0)
	sw	$t1, 12($a0)
	sw	$t1, 16($a0)
	sw	$t1, 20($a0)
	sw	$t1, 24($a0)
	sw	$t1, 28($a0)
	sw	$t1, 32($a0)
	sw	$t2, 36($a0)
	
	addi	$a0, $a0, SHIFT_NEXT_ROW

	sw	$t2, 0($a0)
	sw	$t1, 4($a0)
	sw	$t1, 8($a0)
	sw	$t1, 12($a0)
	sw	$t1, 16($a0)
	sw	$t1, 20($a0)
	sw	$t1, 24($a0)
	sw	$t1, 28($a0)
	sw	$t1, 32($a0)
	sw	$t1, 36($a0)
	sw	$t2, 40($a0)
	
	addi	$a0, $a0, SHIFT_NEXT_ROW

	sw	$t2, 0($a0)
	sw	$t1, 4($a0)
	sw	$t1, 8($a0)
	sw	$t1, 12($a0)
	sw	$t1, 16($a0)
	sw	$t2, 20($a0)
	sw	$t1, 24($a0)
	sw	$t1, 28($a0)
	sw	$t1, 32($a0)
	sw	$t1, 36($a0)
	sw	$t2, 40($a0)
	
	addi	$a0, $a0, SHIFT_NEXT_ROW

	sw	$t2, 0($a0)
	sw	$t2, 4($a0)
	sw	$t1, 8($a0)
	sw	$t1, 12($a0)
	sw	$t2, 16($a0)
	sw	$t2, 24($a0)
	sw	$t1, 28($a0)
	sw	$t1, 32($a0)
	sw	$t2, 36($a0)
	
	addi	$a0, $a0, SHIFT_NEXT_ROW

	sw	$t2, 8($a0)
	sw	$t2, 12($a0)
	sw	$t2, 28($a0)
	sw	$t2, 32($a0)
	
	jr	$ra	


erase_ghost:
	
	li	$t0, COLOUR_BLACK					
	li	$t1, COLOUR_BLACK						
	li	$t2, COLOUR_BLACK						
	

	sw	$t2, 12($a0)
	sw	$t2, 16($a0)
	sw	$t2, 20($a0)
	sw	$t2, 24($a0)
	
	addi	$a0, $a0, SHIFT_NEXT_ROW

	sw	$t2, 8($a0)
	sw	$t1, 12($a0)
	sw	$t1, 16($a0)
	sw	$t1, 20($a0)
	sw	$t1, 24($a0)
	sw	$t2, 28($a0)
	
	addi	$a0, $a0, SHIFT_NEXT_ROW

	sw	$t2, 8($a0)
	sw	$t1, 12($a0)
	sw	$t1, 16($a0)
	sw	$t1, 20($a0)
	sw	$t1, 24($a0)
	sw	$t1, 28($a0)
	sw	$t2, 32($a0)
	
	addi	$a0, $a0, SHIFT_NEXT_ROW

	sw	$t2, 8($a0)
	sw	$t1, 12($a0)
	sw	$t1, 16($a0)
	sw	$t2, 20($a0)
	sw	$t1, 24($a0)
	sw	$t2, 28($a0)
	sw	$t1, 32($a0)
	sw	$t2, 36($a0)	
	
	addi	$a0, $a0, SHIFT_NEXT_ROW

	sw	$t2, 8($a0)
	sw	$t1, 12($a0)
	sw	$t1, 16($a0)
	sw	$t2, 20($a0)
	sw	$t1, 24($a0)
	sw	$t2, 28($a0)
	sw	$t1, 32($a0)
	sw	$t2, 36($a0)
	
	addi	$a0, $a0, SHIFT_NEXT_ROW

	sw	$t2, 4($a0)
	sw	$t1, 8($a0)
	sw	$t1, 12($a0)
	sw	$t0, 16($a0)
	sw	$t1, 20($a0)
	sw	$t1, 24($a0)
	sw	$t1, 28($a0)
	sw	$t0, 32($a0)
	sw	$t2, 36($a0)
	
	addi	$a0, $a0, SHIFT_NEXT_ROW

	sw	$t2, 4($a0)
	sw	$t1, 8($a0)
	sw	$t1, 12($a0)
	sw	$t1, 16($a0)
	sw	$t1, 20($a0)
	sw	$t1, 24($a0)
	sw	$t1, 28($a0)
	sw	$t1, 32($a0)
	sw	$t2, 36($a0)
	
	addi	$a0, $a0, SHIFT_NEXT_ROW

	sw	$t2, 0($a0)
	sw	$t1, 4($a0)
	sw	$t1, 8($a0)
	sw	$t1, 12($a0)
	sw	$t1, 16($a0)
	sw	$t1, 20($a0)
	sw	$t1, 24($a0)
	sw	$t1, 28($a0)
	sw	$t1, 32($a0)
	sw	$t1, 36($a0)
	sw	$t2, 40($a0)
	
	addi	$a0, $a0, SHIFT_NEXT_ROW

	sw	$t2, 0($a0)
	sw	$t1, 4($a0)
	sw	$t1, 8($a0)
	sw	$t1, 12($a0)
	sw	$t1, 16($a0)
	sw	$t2, 20($a0)
	sw	$t1, 24($a0)
	sw	$t1, 28($a0)
	sw	$t1, 32($a0)
	sw	$t1, 36($a0)
	sw	$t2, 40($a0)
	
	addi	$a0, $a0, SHIFT_NEXT_ROW

	sw	$t2, 0($a0)
	sw	$t2, 4($a0)
	sw	$t1, 8($a0)
	sw	$t1, 12($a0)
	sw	$t2, 16($a0)
	sw	$t2, 24($a0)
	sw	$t1, 28($a0)
	sw	$t1, 32($a0)
	sw	$t2, 36($a0)
	
	addi	$a0, $a0, SHIFT_NEXT_ROW

	sw	$t2, 8($a0)
	sw	$t2, 12($a0)
	sw	$t2, 28($a0)
	sw	$t2, 32($a0)
	
	jr	$ra	

draw_fires:
	li	$t0, COLOUR_RED					
	li	$t1, COLOUR_WHITE						
	li	$t2, COLOUR_YELLOW
	li      $t3, COLOUR_ORANGE
  	beq $t6, 8, print_fires_exit  # Print 8 fires, then exit

  # Draw fire at current position
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



clear:	
	li $t9, BASE_ADDRESS
	move $t1, $t9	# $t1 is the counter
	addi $t2, $t1, 32768	# $t2 = last pixel
start_clear:
	bge $t1, $t2, back_main	# run while $t1 < $t2
	sw $zero, 0($t1)		# set the unit to black
	addi $t1, $t1, 4	# increment counter
	j start_clear

back_main:
	jr $ra

game_over:	
	li $t9, BASE_ADDRESS
	move $t1, $t9	# $t1 is the counter
	addi $t2, $t1, 32768	# $t2 = last pixel
	
start_loop_paint_black:
	bge $t1, $t2, end_loop_paint_black	# run while $t1 < $t2
	sw $zero, 0($t1)		# set the unit to black
	addi $t1, $t1, 4	# increment counter
	j start_loop_paint_black	
end_loop_paint_black:	
	
	li $t3, COLOUR_WHITE
	addi $t2, $t9, 8264	# $t2 = middle of screen ish
	sw $t3, 0($t2)
	sw $t3, 16($t2)
	sw $t3, 260($t2)
	sw $t3, 268($t2)
	sw $t3, 520($t2)
	sw $t3, 776($t2)
	addi $t2, $t2, 24
	sw $t3, 0($t2)
	sw $t3, 256($t2)
	sw $t3, 512($t2)
	sw $t3, 768($t2)
	sw $t3, 4($t2)
	sw $t3, 8($t2)
	sw $t3, 772($t2)
	sw $t3, 776($t2)
	sw $t3, 264($t2)
	sw $t3, 520($t2)
	addi $t2, $t2, 16
	sw $t3, 0($t2)
	sw $t3, 256($t2)
	sw $t3, 512($t2)
	sw $t3, 768($t2)
	sw $t3, 8($t2)
	sw $t3, 772($t2)
	sw $t3, 776($t2)
	sw $t3, 264($t2)
	sw $t3, 520($t2)
	addi $t2, $t2, 20
	sw $t3, 0($t2)
	sw $t3, 256($t2)
	sw $t3, 512($t2)
	sw $t3, 768($t2)
	sw $t3, 772($t2)
	sw $t3, 776($t2)
	addi $t2, $t2, 16
	sw $t3, 0($t2)
	sw $t3, 256($t2)
	sw $t3, 512($t2)
	sw $t3, 768($t2)
	sw $t3, 4($t2)
	sw $t3, 8($t2)
	sw $t3, 772($t2)
	sw $t3, 776($t2)
	sw $t3, 264($t2)
	sw $t3, 520($t2)
	addi $t2, $t2, 16
	sw $t3, 0($t2)
	sw $t3, 256($t2)
	sw $t3, 768($t2)
	sw $t3, 4($t2)
	sw $t3, 8($t2)
	sw $t3, 260($t2)
	sw $t3, 516($t2)
	sw $t3, 520($t2)
	sw $t3, 772($t2)
	sw $t3, 776($t2)
	addi $t2, $t2, 16
	sw $t3, 0($t2)
	sw $t3, 4($t2)
	sw $t3, 8($t2)
	sw $t3, 260($t2)
	sw $t3, 516($t2)
	sw $t3, 772($t2)
	
	li $t9, 0xffff0000
	li $v0, 32
	li $a0, 1000
	syscall
	j main


exit:
li $v0, 10	# exit the program
syscall

