.data
	head: 			.word 0            	# Pointer to the head of the linked list (initialized to null)  # integer stack 
	stack_size: 	.word 0      	# Size of the stack (initialized to 0)   #integer stack 
	emptyStack:   	.asciiz "Stack is empty\n"
	newLine: 		.asciiz "\n"
.text
#a0 = value to be push 
push:   
 	# use $t5 , $t0 , $t1
 	addi $sp , $sp , -12
  	sw $t0 , 0 ($sp)
  	sw $t1 , 4 ($sp)
  	sw $t2 , 8 ($sp)      
  	add $t2,$zero,$a0	# assign the value to be pushed in $t2
    
   # System call for memory allocation 
 	li $v0, 9  
 	# Allocate memory for 2 words (node structure)           	
  	li $a0, 8    
  	# Allocate memory and store address in $v0         	
  	syscall               	

 	#move $a0 , $t2
 	# Store the data value in the node's 'value' field
 	sw $t2, 0($v0)        	

 	# Link the new node to the current head of the linked list
 	# Load the current head pointer
  	lw $t0, head          	
  	# Store the address of the current head in 'next' field of the new node
 	sw $t0, 4($v0)      
 	# Update the head pointer to point to the new node  	
 	sw $v0, head          	

 	# Increment the stack size
 	# Load the current stack size
  	lw $t1, stack_size    	
  	# Increment the stack size
  	addi $t1, $t1, 1      	
  	# Store the updated stack size
  	sw $t1, stack_size    	
    	
  	lw $t0 , 0 ($sp)
  	lw $t1 , 4 ($sp)
  	lw $t2 , 8 ($sp)
  	addi $sp , $sp, 12 
  	jr $ra                	
#----------------------------------------------------------------------------------------------------------
# Pop operation to remove a node from the stack
pop:
	#use  #$t0 , $t2  and save $ra 
 	addi $sp , $sp , -12
	sw $ra, 0($sp) 
	sw $t0 ,4($sp) 
	sw $t2 , 8($sp)
	
  	#lw $t0, stack_size           
	lw $t0, head
	# Check if the stack is empty (head is null)
 	beq $t0, $zero, pop_empty  	
	
 	# Update the head pointer to point to the next node
 	# Load the address of the next node
 	lw $t0, 4($t0)        		
 	# Update the head pointer
 	sw $t0, head          		

  	# Decrement the stack size
  	# Load the current stack size
 	lw $t2, stack_size    	
 	# Decrement the stack size
  	addi $t2, $t2, -1     	
  	# Store the updated stack size
  	sw $t2, stack_size    	
    	
 	j exitePop
	pop_empty:
   	# Stack is empty, handle error or return safely
    	la $a0, emptyStack
   	jal printString 
	exitePop:
		lw $ra, 0($sp) 
		lw $t0 ,4($sp) 
		lw $t2 , 8($sp)
		addi $sp , $sp , 12
   	jr $ra  # return to the caller (evaluation function )
#----------------------------------------------------------------------------------------------------------
# Get the size of the stack
size:
	# Load the stack size
  	lw $v0, stack_size    	
  	jr $ra                	# Return to the caller    
#----------------------------------------------------------------------------------------------------------
# Top operation to return the value at the top of the stack
top:
	# lw $t0, stack_size           	
 	# use $t0 so save it to the Memory
	addi $sp , $sp , -4 
	sw $t0 , 0 ($sp)
    	
  	lw $t0, head
  	# Check if the stack is empty (head is null)
 	beq $t0, $zero, top_empty  	
   # Load the value stored in the top node 	
 	lw $v0, 0($t0)       
 	# Return to the caller 	
  	j exit_top              	

	top_empty:
  		# Stack is empty, handle error or return safely
  		# Return -1 (or set to an appropriate error value)
  		li $v0, -1           	

 	exit_top:
    	lw $t0 , 0 ($sp)
    	addi $sp , $sp , 4
    	jr $ra               	 
#----------------------------------------------------------------------------------------------------------
isEmpty:
    	# Load the head pointer     	
    	lw $v0, head
    	# Set $v0 to 1 if head is null (stack is empty), otherwise 0
    	seq $v0, $v0, $zero   		
    	jr $ra                		
#----------------------------------------------------------------------------------------------------------
# function to delete all element to the stack 
free:
	# it use $t0 so save it to the memory 
	addi $sp , $sp , -4 
	sw $t0 , 0 ($sp ) 
  	#load the head to $t0 
	lw $t0, head
	#loop untill $t0 = 0 (first head )
	loopEmpty:
		beq $t0, $zero, exitLoopEmpty
		lw $t0, 4($t0)
		j loopEmpty
	exitLoopEmpty:	
		sw $t0, head
		lw $t0 , 0 ($sp)
		addi $sp , $sp ,4
		jr $ra
#----------------------------------------------------------------------------------------------------------
# function to print stack elements
print:
	addi $sp, $sp, -8
	sw $ra, 0($sp)
	sw $t0 , 4($sp)

	lw $t0, head					# the top pointer
	bne $t0, $zero, loopPrint				# check if it's empty
	
	la $a0, emptyStack				# message
 	jal printString  
    	
 	j exitLoopPrint
	loopPrint:
		# check if the pointer reached null
		beq $t0, $zero, exitLoopPrint		
		# printing the current value
		lw $a0, 0($t0)				
		jal printInteger		
		jal printNewLine		
		# moving to the next node
		lw $t0, 4($t0)				
	 	j loopPrint
	exitLoopPrint:	
		lw $ra, 0($sp)
		lw $t0 , 4($sp)
		addi $sp, $sp, 8
		jr $ra
#----------------------------------------------------------------------------------------------------------
printNewLine:
	la $a0, newLine
	li $v0, 4
	syscall
	jr $ra		
#----------------------------------------------------------------------------------------------------------
printInteger:
	li $v0, 1
	syscall
	jr $ra
#----------------------------------------------------------------------------------------------------------
printString:
	li $v0, 4
	syscall
	jr $ra
#----------------------------------------------------------------------------------------------------------
printCharacter:
	li $v0, 11
	syscall
	jr $ra


