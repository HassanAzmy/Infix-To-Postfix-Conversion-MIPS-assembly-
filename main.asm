.data
# Global variables
	fail_msg: 			.asciiz "Expression is not valid.\n"
	restart: 			.asciiz  "please press any key in the keyboard to  restart the program..."
	restart_done: 		.asciiz "Restart Done\n"
	space:				.asciiz " "		
	tempExpression: 	.space 1200
	prompt:       		.asciiz "Enter infixExpression : "
	valuPrint:      	.asciiz "Value: "
	POS_Str:         	.asciiz "postfix Expression = "
	STANDARD_STR:   	.asciiz "Standard Expression = "
.text
.globl main
main:
		# tempexpression --> filteredExpression --> standardExpression
		la $a0 , prompt
      jal printString					# prompt message
         
      la $a0 , tempExpression
      li $a1 , 300
      li $v0 , 8 
      syscall								# input expression

	 	la $t0 , tempExpression 		# expression's address
     	la $t1 , filteredExp	# filtered expression's address
      li $t3 , ' '
      li $t4 , '\n'
      Filterloop:
         lb $t2 , 0($t0)			# load from expression
         beq $t2 , $zero , null
         beq $t2 , $t3 , incrementFlterLoop
         beq $t2 , $t4 , incrementFlterLoop
         sb $t2 , 0($t1)		# store in the filtered one
         addi $t1 , $t1 , 1
         incrementFlterLoop:
            addi $t0 , $t0 , 1
            j Filterloop                    
     		null:
        		sb $t2 , 0($t1)					# null terminating the filtered expression
       		j exiteFilterLoop                 
      exiteFilterLoop:
    	jal toStandardInfix 
    	la $a0, STANDARD_STR        		# Load address of res
    	jal printString

  		la $a0, standardExp        # Load address of res
   	jal printString
    	jal printNewLine   	 
   	 
   	# Load address of the string into $a0
  	  	la $a0, standardExp
  	  	# Call the Bal function to check parentheses balance
    	jal validParentheses
    	
    	beq $v0,$0,not_valid
   	# Call the isValidExpression function
   	la $a0 , standardExp
    	jal isValidExpression

    	# Check the result
      bne $v0, $zero, valid
		not_valid:
			la $a0 , fail_msg
			jal printString
	
			la $a0 , restart
			jal printString
	
			li $v0 , 12   # system call for read char  
			syscall 
			li $t0 , 0 
			li $t1 ,20 
	
		newLineLOOP:
	    beq $t0 , $t1 ,  exite_newLineLOOP	    
	    jal printNewLine	    
	    addi $t0 , $t0 ,1 
	    j newLineLOOP
	    
		exite_newLineLOOP:
	    la $a0 , restart_done
	    jal printString	       	    
	    j main
  	 
      valid:      
       	la $t0 , standardExp
       	la $t1 , expression
      copyloop1:
         lb $t2 , 0($t0)
         beq $t2 , $zero , null12
         sb $t2 , 0($t1)
         addi $t1 , $t1 , 1
         addi $t0 , $t0 , 1
         j copyloop1
         null12:
         	sb $t2 , 0($t1)
         	j exitecopyloop1                 
      exitecopyloop1:
         
		jal Infix_to_postfix
		
      la $a0 , POS_Str
      jal printString
        	    
     	la $s4, string_array
 		li $s5, 0
 		lw $t6, array_size
 		
  		print_postfix_loop:
      	bge $s5, $t6, end_print_postfix_loop  
   		sll $t7, $s5, 2
   		add $t7, $t7, $s4
    		lw $t8, 0($t7)   			
    		move $a0, $t8
     		jal printString    
       	addi $s5, $s5, 1        
   		j print_postfix_loop
     	end_print_postfix_loop:
 		jal printNewLine    		   
  		la $a0 , string_array
  	  	jal Evaluation

   	move $t0 , $v0    # $t0 contane the result  
     	la $a0 , valuPrint
   	jal printString

  		li $v0 , 1 
  		move $a0 , $t0 
  		syscall
	
		li $v0, 10 # end program
   	syscall
.include "toStandardInfix.asm"
