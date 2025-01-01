Evaluation:
	#a0 address of the refrance array of  strings
	#loop for each string refrance in the array 
	#counter i
	li $t7 , 0   
	lw $t6 , array_size 
	# address of refrance array 
	move $s2 , $a0   

	# saving the return address in the stack  
	addi $sp, $sp, -4    
	sw   $ra, 0($sp)
	#move $t8 , $ra
	#ra is the position in the main function 

	loop:
		beq $t7 , $t6 , exite_loop

		# load the address of string 
		# refrance of string 
 		lw $a0 , 0 ($s2)  
		lb $a0 , 0 ($a0)
		beq $a0 , $zero , increment2
		jal isOperator

		beq $v0 , $0 , Number

		# get the top in v0 
		jal top   
		# b  
 		move $s3 , $v0   
 		jal pop 
 		# get the top in v0 
 		jal top    
 		# a 
		move $s4, $v0    
		jal pop 
		move $a0 , $s4
		move $a1 , $s3 
		lw $t0, 0($s2)	
		lb $a2 , 0($t0)
		jal makeoperation
		move $a0 , $v0 
		jal push
		increment2:
			addi $s2 , $s2 , 4 
			addi $t7  , $t7, 1
 			j  loop
		Number:
			# refrance of string to a0 
 			lw $a0 , 0 ($s2)  
  			jal strToInt
  			move $a0 , $v0 
  			jal push 
 			addi $s2 , $s2 , 4 
			addi $t7  , $t7, 1
			j  loop

	exite_loop:
		# result in $v0
  		jal top 
  		lw   $ra, 0($sp)    
   	addi $sp, $sp, 4   
   	jr $ra
#----------------------------------------------------------------------------------------------------------
# Function to convert a null-terminated string to an integer
# $a0: pointer to the input string
# Returns: the integer value of the string in $v0
strToInt:
    # use $t0 , $t1  , $t2, $t3  so save them in momory
    	addi $sp, $sp, -16
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
    
    # Initialize variables
    # Loop counter i
    li $t0, 0        
    # Initialize ans to 0
    li $t1, 0        

	strToInt_loop:
		# Load the byte (character) from the string into $t2
   	lb $t2, 0($a0)   
   	# If the byte is 0 (null terminator), exit loop
   	beqz $t2, strToInt_done   
    
    	# ASCII value of '0'
    	li $t3, 48       
   	sub $t2, $t2, $t3

    	# Multiply ans by 10
    	mul $t1, $t1, 10

    	# Add the converted character to ans
   	add $t1, $t1, $t2

    	# Increment loop counter and pointer to next character
   	addi $t0, $t0, 1
   	addi $a0, $a0, 1

    	# Repeat the loop
    	j strToInt_loop

	strToInt_done:
  		# Return the result in $v0
  		# Move the result to $v0
  		move $v0, $t1        
  		lw $t0 , 0($sp)
		lw $t1 , 4 ($sp)
   	lw $t2 , 8 ($sp)
   	lw $t3 , 12 ($sp)
   	addi $sp  , $sp, 16 
    	jr $ra           
#----------------------------------------------------------------------------------------------------------
makeoperation:
	#arguments   ---->  operand1 a0,  operand a1 and operation a2
	
	 #use $t0  so save it on the memory
	 addi $sp , $sp , -4 
	 sw $t0 , 0($sp)
	#checking if the operation is +
	li $t0, '+'   
	beq $a2, $t0, plus_exit
	
	#checking if the operation is -
	li $t0, '-'   
	beq $a2, $t0, minus_exit
	
	#checking if the operation is *
	li $t0, '*'   
	beq $a2, $t0, mult_exit
	
	#checking if the operation is /
	li $t0, '/'   
	beq $a2, $t0, divison_exit
	
	#checking if the operation is ^
	li $t0, '^'   
	beq $a2, $t0, exponent_exit
	
	# if the input is invalid  
	# flag ig operation is invalid
	add $t1, $a0, $0   
	j exiteMakeoperation
	
	plus_exit:
		add $v0, $a0, $a1
		j exiteMakeoperation
 	
	minus_exit:
		sub $v0, $a0, $a1
		j exiteMakeoperation
 
	mult_exit:
		mul $v0, $a0, $a1
		j exiteMakeoperation
 	
	divison_exit:
		div $v0, $a0, $a1
		j exiteMakeoperation
 	
	exponent_exit:
    		addi $sp, $sp, -4    # saving the return address in the stack  
    		sw   $ra, 0($sp)
    		jal power           # calling power function
    		lw   $ra, 0($sp)    # restoring the return address
    		addi $sp, $sp, 4    # restore stack pointer to deallocate space for the return address
    
		j exiteMakeoperation
	exiteMakeoperation:
		lw $t0 , 0($sp)
		addi $sp , $sp, 4 
		jr $ra 
#----------------------------------------------------------------------------------------------------------
power:
	#arguments: base ---> a, exponenet ----> a1      2,3
	# use $t0 , $t1 , $t2 
	addi $sp , $sp, -12 
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	# result t1 = 1
	addi $t1, $0, 1  
	# index = 0 
	add $t0, $0, $0   
	loop1:
		slt $t2, $t0, $a1
		# if index > exponenet ----> exit loop
		beq  $t2, $0, exit_loop1    
		#  operation
		mul $t1, $t1, $a0   
		# incrementing index
		addi $t0, $t0, 1    
		j loop1
	exit_loop1:
		# result in V0
		add $v0, $t1, $0  
   	lw $t0 , 0($sp)
 		lw $t1 , 4 ($sp)
  		lw $t2 , 8 ($sp)
   	addi  $sp , $sp , 12 
		jr $ra	
#----------------------------------------------------------------------------------------------------------
isOperator:    
 	addi $sp , $sp , -24 
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	sw $t4, 16($sp)
	sw $t5, 20($sp)
	
	move $v0, $zero
	move $t0, $a0	
	li $t1, '+' 	 
	li $t2, '-' 	 
	li $t3, '*'	 
	li $t4, '/'	 
	li $t5, '^'   

	beq $t0, $t1, set
	beq $t0, $t2, set
	beq $t0, $t3, set
	beq $t0, $t4, set
	beq $t0, $t5, set
	j exit
	#exit label change boolean value
	set:
		addi $v0, $zero, 1
	exit:
  		lw $t0 , 0($sp)
 		lw $t1 , 4 ($sp)
   	lw $t2 , 8 ($sp)
    	lw $t3 , 12 ($sp)
    	lw $t4 , 16 ($sp)
    	lw $t5 , 20 ($sp)
  		addi $sp ,$sp , 24
		jr $ra	
.include "Stack.asm"
