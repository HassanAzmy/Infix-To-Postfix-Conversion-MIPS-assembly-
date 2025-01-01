.data
	array_size: 		.word 0	
	string_array: 		.space 1000
	tempStringSize: 	.word 0
	tempString:  		.space 36
	expression:  		.space 1200
.text
Infix_to_postfix:
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	# temp --> to split the expression
	li $t2, 0	
	# i	
	li $t4, 0		
	stringLoop:
		# $t5 = expression[i]
		lb $t5, expression($t4)	
		# if(expression[i] == '\n') break		
		beq $t5, '\n', exitStringLoop	
		# if(null-terminated) break
		beq $t5, $zero, exitStringLoop
		# if(expression[i] == ' ') continue		
		beq $t5, ' ', increment			

		# isDigit's argument
		move $a1, $t5			
		# $v0 = isDigit(expression[i])	
		jal isDigit				
		# if(isOperator(expression[i])) jump
		beq $v0, $zero, operator		
		innerLoop:
			# if(expression[i]) == ' ') continue
			beq $t5, ' ', increment		
			# $t3 = int(expression[i])
			addi $t3, $t5, -48	
			# temp = temp * 10	
			mul $t2, $t2, 10		
			# temp = temp * 10 + int(exp[i])
			add $t2, $t2, $t3	
			# i ++	
			addi $t4, $t4, 1		
			
			lb $t5, expression($t4)
			# if(expression[i] == '\n') break
			beq $t5, '\n', exitStringLoop	
			# if(null terminated) break 
			beq $t5, $zero, exitStringLoop		
			
			# isDigit's argument
			move $a1, $t5		
			# $v0 = isDigit(expression[i])	
			jal isDigit			
			# if(!isDigit(exp[i]))	break
			bne $v0, $zero, innerLoop	
		exitInnerLoop:	
			# i --
			addi $t4, $t4, -1		
			# toString's argument
			move $a0, $t2
			# toString(temp)			
			jal toString		
			# pushStringToArray()	
			jal pushStringToArray		
			# temp = 0	
			li $t2, 0			
			# i++ and loop			 
			j increment			
		operator:
			beq $t5, '(', leftParenthesis	
			beq $t5, ')', rightParenthesis	
			bge $t5, 42, else
			
			# if(expression[i] == '(') push
			leftParenthesis:		
				# stackPush's argument
				move $a0, $t5		
				# stackPush(exp[i])
				jal push		
				# i++ and loop
				j increment		
						
			rightParenthesis:		
				parenthesisLoop:
					# $v0 = stackTop()
					jal top		
					# $t6 = top of the stack
					move $t6, $v0		
					# loop until '(' is found
					beq $t6, '(', exitParenthesisLoop	
					
					# Push expression[i] to the stack
					# pushToString's argument
					move $a1, $t6		
					# pushToString(stackTop())	
					jal pushToString	
					# push the popped operator to the array
					jal pushStringToArray	
					# stackPop()
					jal pop	
					# loop	
					j parenthesisLoop	
				exitParenthesisLoop:
					# stackPop()
					jal pop		
					# i++ and loop
					j increment		
			else:
				elseLoop:
					# $v0 = stackTop()
					jal top	
					# $t6 = $v0 		
					move $t6, $v0		
					# exit if stack is empty	
					beq $t6, -1, exitElseLoop	
										
					# if(stackTop() == '^') t0 = 1 
					seq $t0, $t6, '^'		
					# if(exp[i] == '^') t1 = 1 
					seq $t1, $t5, '^'		
					# $t1 = $t0 & $t1
					and $t1, $t1, $t0		
					# if(stackTop() == '^' && exp[i] == '^') push(exp[i])
					beq $t1, 1, exitElseLoop	
					
					# periority's argument
					move $a0, $t5			
					# $v0 = periority(exp[i])
					jal periority			
					# $t7 = returned value 
					move $t7, $v0			
					
					# periority's argument
					move $a0, $t6			
					# $v0 = periority(stackTop())
					jal periority			
					# if(priority[exp[i]] > priority[stackTop()]) Push(exp[i])
					bgt $t7, $v0, exitElseLoop	
					
					# pushToString's argument
					move $a1, $t6			
					# pushToString(stackTop())	
					jal pushToString		
					# push the popped operator to the array
					jal pushStringToArray		
					# stackPop()
					jal pop	
					# loop		
					j elseLoop			
				exitElseLoop:
					# stackPush's argument
					move $a0, $t5			
					# stackPush(exp[i])		
					jal push			
		increment:
			# i++
			addi $t4, $t4, 1	
			# loop
			j stringLoop		
	exitStringLoop:
		# i-- --> expression.size
		addi $t4, $t4, -1			
		# $t1 = expression[size - 1]
		lb $t1, expression($t4)			
		# if(expression[size - 1] == ')') empty the stack
		beq $t1, ')', stackNotEmptyLoop		
		# toString's argument
		move $a0, $t2				
		# toString(exp[size - 1])
		jal toString				
		# pushStringToArray()
		jal pushStringToArray			
	
	stackNotEmptyLoop:
		# $v0 = stackTop()
		jal top		
		# $t6 = $v0	
		move $t6, $v0			
		# if(stackEmpty()) don't loop on the stack
		beq $t6, -1, exitStackNotEmptyLoop	
	
		# pushToString's argument
		move $a1, $t6		
		# pushToString(stackTop())
		jal pushToString	
		# pushStringToArray()
		jal pushStringToArray	
		# stackPop()
		jal pop		
		# loop
		j stackNotEmptyLoop	

	exitStackNotEmptyLoop:
	
		lw $ra, 0($sp)
		addi $sp, $sp, 4
    	jr $ra

#----------------------------------------------------------------------------------------------------------
toString:	# String toString(int num)
	addi $sp, $sp, -4
	sw $ra, 0($sp)
    	
	li $t1, 10      	# base
	move $t2, $a0       	# num
	li $t3, 0           	# i

	convert_loop:
		# num / 10
    	div $t2, $t1  
    	# $t9 = num % 10    		
   	mfhi $t9          
   	# $t9 = char(num)		
   	addi $t9, $t9, 48 
   	# storing the char in tempString     		
    	sb $t9, tempString($t3)  
   	# get the quotient   	
   	mflo $t2       
    	# increment i       		
    	addi $t3, $t3, 1   
    	# repeat until quotient is zero    		
    	bnez $t2, convert_loop 		
    	j reverse

	reverse:
   	li $t1, 0		
   	# store the size of the tempString
    	sw $t3, tempStringSize	
    	# the last index of the string
    	addi $t3, $t3, -1   	

	reverse_loop:
		# Exit loop if start index >= end index
  		bge $t1, $t3, reverse_done  	
  		# Load character at start index
   	lb $t2, tempString($t1)		
   	# Load character at end index
  		lb $t8, tempString($t3)         
  		# Store character from end index at start index
    	sb $t8, tempString($t1)         
    	# Store character from start index at end index
    	sb $t2, tempString($t3)       
    	# Move start index forward  
    	addi $t1, $t1, 1          
    	# Move end index backward  	
   	addi $t3, $t3, -1  
   	# loop        	
    	j reverse_loop			

	reverse_done:
   	lw $ra, 0($sp)
    	addi $sp, $sp, 4
    	jr $ra
#----------------------------------------------------------------------------------------------------------
isDigit:	# bool isDigit(char c);
		# Set the default value to 0
    	li $v0, 0          
    	# if(exp[i] < '0') return 0
    	blt $a1, '0', end_isDigit	
    	# if(exp[i] > '9') return 0
    	bgt $a1, '9', end_isDigit	
    	# if(exp[i] >= '0' && exp[i] <= '9') return 1
    	li $v0, 1          

	end_isDigit:
    	jr $ra             # return
#----------------------------------------------------------------------------------------------------------
pushToString:	# void pushToString(char c);
	# index where we will push the char	
	lw $t0, tempStringSize		
	# tempString[size] = c
	sb $a1, tempString($t0)		
	# size ++
	addi $t0, $t0, 1		
	# updating the size of the tempString
	sw $t0, tempStringSize		
	jr $ra
#----------------------------------------------------------------------------------------------------------
pushStringToArray:	# void pushStringToArray(string str);
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	# last index of the tempString
	lw $t0, tempStringSize		
	# pushing a null terminator
	sb $zero, tempString($t0)	
	
	# Allocating memory
	# allocating a memory whose address will be stored in $v0
	li $v0, 9			
	# size of the memory allocated (10 bytes)
	li $a0, 10			
	syscall
	# $t2 = address for the memory allocated
	move $t9, $v0			
	
	# copyString 1st's argument
	la $a1, tempString		
	# copyString 2nd's argument
	move $a2, $t9		
	# copyString(str1, str2)	
	jal copyString			
	
	# $t3 = array size
	lw $t3, array_size
	# offset = $t3 * 4		
	sll $t3, $t3, 2			
	# pushing the allocated memory address in the array 
	sw $t9, string_array($t3)	
	
	# $t3 = array size
	lw $t3, array_size	
	# incrementing the size	
	addi $t3, $t3, 1		
	# updating the size
	sw $t3, array_size		
		
	# $t0 = 0	
	li $t0, 0			
	# pointer of the tempString to index 0
	sw $t0, tempStringSize		
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
#----------------------------------------------------------------------------------------------------------
copyString:	# copyString(string str1, string str2)
	# Counter $s0 = 0
	li $s0, 0	
	copyStringloop:
		# address of tempString[i]
		add $t1, $s0, $a1	
		# $t2 = name[i]
		lb $t8, 0($t1)		
		# if(str1[i] == '\0')	break		
		beq $t8, $zero, exitCopyStringLoop	
		# address of memory allocated	
		add $t1, $s0, $a2		
		# copying the character		
		sb $t8, 0($t1)			
		# increment $s0
		addi $s0, $s0, 1		
		# Loop until reaching the null terminator
		j copyStringloop	
	exitCopyStringLoop:
	jr $ra
#----------------------------------------------------------------------------------------------------------
periority:   
	addi $sp, $sp, -4
	sw $t5, 0($sp)

	# ASCII for '+'
	li $t1, '+'  
	# ASCII for '-'
	li $t8, '-'  
	# ASCII for '*'
	li $t9, '*'  
	# ASCII for '/'
	li $t0, '/'  
	# ASCII for '^'
	li $t5, '^'  

   # Check the input character and return priority
   beq $a0, $t1, plus_minus_label
   beq $a0, $t8, plus_minus_label
   beq $a0, $t9, multiply_division_label
   beq $a0, $t0, multiply_division_label
   beq $a0, $t5, exponential_label

	li $v0, 0
	j returnPriority
    	
	plus_minus_label:
		# Return 1 for '+' or '-'
		li $v0, 1   
		j returnPriority
    
	multiply_division_label:
		# Return 2 for '*' or '/'
    	li $v0, 2   
    	j returnPriority
    
	exponential_label:
		# Return 3 for '^'
   	li $v0, 3   
    	j returnPriority
    		
  	returnPriority:
		lw $t5, 0($sp)
		addi $sp, $sp, 4
		jr $ra
.include "ExpressionEvaluation.asm"
