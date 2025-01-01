.data
	filteredExp:  	.space 1200
	standardExp:  	.space  1200     
	minusMul: 		.asciiz  "(0-1)*"
	minusDiv: 		.asciiz  "(0-1)/"
.text
toStandardInfix:
	addi   $sp ,$sp ,-4 
	sw $ra , 0($sp)
	
	# counter i 
	li $t3 , 0    		
	# &filtered expression 					
	la $s0 , filteredExp  
	# standardExpression size 	
	li $s1 ,0   			
	# &standardExpression 				
	la $s2 , standardExp	
	
	to_standard_infix_loop:
		# t1 --> s[i]        t0 --> s[i-1]	
		# load from filteredExpression	
		lb $t1 , 0($s0) 					
		# if(null-terminator) break
		beq $t1 , $zero , end_to_standard_loop 
		# if(i != 0) jump
		bne $zero ,$t3  , I_largThanZero		
		# if(s[0] == '-') push (0-1)*	
   	beq $t1, '-', Edit_for_multiplication	
   	# if(exp[0] == '+') continue
		beq $t1 , '+', next_iteration		
		# if(exp[0] != '-' && exp[0] != '+') push			
		j push_to_res									
		
		I_largThanZero:
			# filteredExpression[i-1]
			lb $t0 , -1($s0)  					
		   # if(exp[i] != '+') jump  	
			bne $t1 , '+' , continue			
		     		
		  	# if(exp[i] == '+')
		  	# $v0 = isOperator(exp[i-1])
			move $a0 , $t0	
    		jal isOperator     				
    		# if(exp[i]=='+' && isOperator(exp[i-1]))	continue	
       	beq $v0,$0, handlerightbracket
      	j next_iteration				
       		      
     		handlerightbracket:
     			# if(exp[i]=='+' && exp[i-1] == '(')	continue
       		beq $t0 , '(' , next_iteration	
       		# else
       		j push_to_res				
		
				# if(exp[i] != '+')	     
        	continue:
        		# if(exp[i] != '(')	jump
        		bne $t1, '(',continue2	
        		# if )( --> push '*'	
           	beq $t0,')',add_asterisk   
           	   
           	# isDigit(s[i-1])
          	move $a1 , $t0
          	jal isDigit 
          	# if(!isDigit(s[i-1])) jump  						
          	beq $v0,$0, continue2
          	# if A( --> push '*'    			
          	j add_asterisk						      	 
		
				# if(exp[i] != '(' || !isDigit(exp[i-1]))
      	continue2: 
      		# if(exp[i] != '-') push s[i]
          	bne $t1, '-', push_to_res	
                	
           	# if(exp[i] == '-')  
           	# $v0 = isOperator(s[i-1])      
          	move $a0 , $t0
           	jal isOperator    
           	# if(!isOperator(s[i-1])) jump    			
          	beq $v0, $0, not_operator 	   
                	
         	# if(isOperator(s[i-1]))
         	# if /-	--> push (0-1)/
           	beq $t0, '/', Edit_for_division	
           	# else  --> push (0-1)*
          	j Edit_for_multiplication			
      	not_operator:
      		# if (- --> push (0-1)*
         	beq $t0,'(',Edit_for_multiplication	
         	# else
          	j push_to_res								

      	Edit_for_multiplication:
      		# push (0-1)*
        		la $a1, minusMul		
          	jal Copy_additional_expression		
           	j next_iteration
     		Edit_for_division:
     			# push (0-1)/
         	la $a1, minusDiv
          	jal Copy_additional_expression	
          	j next_iteration
         
        	add_asterisk:
        		# Load the ASCII code for '*'
        		li $t4, '*'    			
        		# next standardExp's idx	
       		add $t8 , $s2 , $s1   	
       		# Storing an * 	
        		sb $t4, 0($t8)        	
        		# increase the size of the standardExp 	
        	 	addi $s1, $s1 , 1  
        	 	# pushing the '('  		
        		j push_to_res					

    		push_to_res:
    			# next standardExp idx
       		add $t8 , $s2 , $s1	
       		# store filteredExp[i] in standardExp	
        	 	sb $t1, 0($t8) 
        	 	# increase the size of the standardExp            	
        		addi $s1, $s1 , 1         	
       	next_iteration:
       		# i ++
				addi $t3, $t3 , 1				
				addi $s0, $s0 , 1				 
         	j to_standard_infix_loop
	end_to_standard_loop:
	
    	add $t8 , $s2 , $s1   
     	sb $zero, 0($t8)                	
    	lw $ra , 0($sp)
   	addi $sp , $sp , 4 
     	jr $ra				
#----------------------------------------------------------------------------------------------------------
# a1 --> the string to be copied ("(0-1)")
# copy loop function 
Copy_additional_expression:
  	addi $sp , $sp , -16 
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
   
   # &standardExp
	la  $t0  , standardExp   
	# &minusDiv or & minusMul
  	move $t1 , $a1   		
	# index of the standardExp
	add $t0 , $t0 , $s1   				
   	
 	Copy_additional_expression_loop:
  		# Load from minusMul or minusDiv
  		lb  $t2, 0($t1)   
  		# if(null-terminator)	break    			
 		beq  $t2, $zero, done_copy 
 		# store in standardExp 	
 		sb   $t2, 0($t0)
		# incerment both memory locations       			
		addi $t0, $t0, 1             	
  		addi $t1, $t1, 1
  		# increment standardExp's size      
  		addi $s1 , $s1,1 
  		# loop  				 
  		j  Copy_additional_expression_loop
  	done_copy:
    	lw $t0 , 0($sp)
    	lw $t1 , 4 ($sp)
    	lw $t2 , 8 ($sp)
    	lw $t3 , 12 ($sp)
    	addi $sp , $sp , 16
   	jr $ra
#----------------------------------------------------------------------------------------------------------
isValidExpression:
    addi $sp, $sp, -16   
    sw $ra, 0($sp)      
    sw $t0, 4($sp)
    sw $t1, 8($sp)
    sw $t2, 12($sp)
    
    # &standardExp
    move $t2 , $a0    
    # flag for the previous char 
    # 1-->digit, 2-->operator
    # 3-->'(',   4-->')'
    li $t0, -1           

    IsvalidLoop:
    	# load from standardExp
   	lb $t1, 0($t2)  
   	# if('\n') break
   	beq $t1, '\n', end_loop
   	# if(null-terminator) break
    	beqz $t1, end_loop  
    	# moving to next character
   	addi $t2, $t2, 1  
        
   	# Check character
    	beq $t1, '(', check_open_bracket
     	beq $t1, ')', check_close_bracket
        
  		# call isDigit function    $v0 return flage 
    	move $a1 , $t1
     	jal isDigit         # check if character is a digit
        
   	bne $v0, $zero, checkDigit
        
    	# call is operator function  
    	move $a0 , $t1 
     	jal isOperator
     	# if not a digit, check if it's an operator
     	bne $v0, $zero, check_operator  

    check_open_bracket:
    	# if previous was ')' or initial, return false
   	beq $t0, 4, unbalanced 
   	# if previous was a digit, return false 
     	beq $t0, 1, unbalanced 
     	# set prev = 3 (for '(')
    	li $t0, 3               
     	j IsvalidLoop

    check_close_bracket:
    	# if previous was initial, return false
     	beq $t0, -1, unbalanced 
     	# if previous was '(', return false
     	beq $t0, 3, unbalanced  
     	# if previous was operator , return false
     	beq $t0, 2, unbalanced  
     	# set prev = 4 (for ')')
     	li $t0, 4               
     	j IsvalidLoop
	checkDigit:
   	beq $t0, 4, unbalanced
  	  	li $t0, 1
    	j IsvalidLoop    

    check_operator:
    	# if previous was initial, return false
    	beq $t0, -1, unbalanced  
    	# if previous was an operator, return false
    	beq $t0, 2, unbalanced   
    	# if previous was '(', return false
    	beq $t0, 3, unbalanced  
    	# set prev = 2 (for operator) 
  		li $t0, 2                
     	j IsvalidLoop

    end_loop:
    	# if previous was '(', return false
    	beq $t0, 3, unbalanced   
    	# if previous was an operator, return false
    	beq $t0, 2, unbalanced   
    	# return 1 (true)
     	li $v0, 1                
     	j end_expression

    unbalanced:
    	# return 0 (false)
   	li $v0, 0                

    end_expression:
   	 lw $ra, 0($sp)      
   	 lw $t0 , 4($sp)
   	 lw $t1 , 8($sp)
    	 lw $t2, 12 ($sp)
    	 addi $sp , $sp 16
       jr $ra                    
#----------------------------------------------------------------------------------------------------------
validParentheses:
    addi $sp, $sp, -4   
    sw $ra, 0($sp)      
    
    # counter i
    li $t0, 0           

    # Loop over the string
    loop2:
    	# load from standardExpression
   	lb $t1, 0($a0)  
   	# if(null-terminator) break
    	beqz $t1, end_loop2 
    	# moving to the next character
     	addi $a0, $a0, 1  

     	# increment counter if '('
  		beq $t1, '(', increase_cnt
  		# decrement counter if ')'
    	beq $t1, ')', decrease_cnt
    	# loop
     	j loop2           

    increase_cnt:
    	# increment counter
    	addi $t0, $t0, 1  
     	j loop2

    decrease_cnt:
    	# decrement counter
    	addi $t0, $t0, -1 
    	# if(counter < 0) return 0
     	bltz $t0, unbalanced2
     	j loop2

    unbalanced2:
    	# return 0
     	li $v0, 0          
     	j end_balance2

    end_loop2:
    	# if(counter != 0) return 0
     	bnez $t0, unbalanced2
     	# else return 1
     	li $v0, 1       

    end_balance2:
        lw $ra, 0($sp)
        addi $sp, $sp, 4
        jr $ra 
.include "infixToPostifConverter.asm"
