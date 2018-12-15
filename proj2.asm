.data
    nullErr:	.asciiz "Input is empty."
    lenErr: .asciiz "Input is too long."
    baseErr:   .asciiz "Invalid base-32 number."
    input:		.space 50
.text
    main:
	li $v0, 8        
	la $a0, input
	li $a1, 50
	syscall
	
	removeLeading:  #Remove leading spaces
	li $t8, 32      #Save space char to t8
	lb $t9, 0($a0)
	beq $t8, $t9, removeFirst
	move $t9, $a0
	j checkLength

	removeFirst:
	addi $a0, $a0, 1
	j removeLeading

	#counting the length of ths tring
	checkLength:   
	addi $t0, $t0, 0  #start @ zero
	addi $t1, $t1, 10  
	add $t4, $t4, $a0  #since a0 gets eliminted every syscall --> this keeps it in t4 to save it

	lengthLoop:
	lb $t2, 0($a0)   #put the next char into t2
	beqz $t2, done   #end if zero
	beq $t2, $t1, done   #end if no line
	addi $a0, $a0, 1   #+1 the string pointer
	addi $t0, $t0, 1
	j lengthLoop

	done:
	beqz $t0, nullError   #Bif len(arr) = 0 then go to error
	slti $t3, $t0, 5      #check that it is less than 5
	beqz $t3, lengthError #if it too big throw an errorw
	move $a0, $t4
	j checkStr

	nullError:
	li $v0, 4
	la $a0, nullErr
	syscall
	j exit
	
	lengthError:
	li $v0, 4
	la $a0, lenErr
	syscall
	j exit

	checkStr:
	lb $t5, 0($a0)
	beqz $t5, conversionStart  #End loop if null char is reached
	beq $t5, $t1, conversionStart  #End loop if end-of-line char is detected
	slti $t6, $t5, 48    #Check if the char is less than 0 not valid
	bne $t6, $zero, baseError
	slti $t6, $t5, 58    #Check if the char is less than 58->9 
	bne $t6, $zero, Increment
	slti $t6, $t5, 65    #Check if the char is less than 65->A not valid
	bne $t6, $zero, baseError
	slti $t6, $t5, 86    #Check if the char is less than 89->Y
	bne $t6, $zero, Increment
	slti $t6, $t5, 97    #Check if the char is less than 97->a not valid
	bne $t6, $zero, baseError
	slti $t6, $t5, 118   #Check if the char is less than 121->y 
	bne $t6, $zero, Increment
	bgt $t5, 117, baseError   #Check if the char is greater than 120->x not valid

	Increment:
	addi $a0, $a0, 1
	j checkStr

	baseError:
	li $v0, 4
	la $a0, baseErr
	syscall
	j exit

	conversionStart:
	move $a0, $t4
	addi $t7, $t7, 0  #start the decimal  sum at zero
	add $s0, $s0, $t0
	addi $s0, $s0, -1	
	li $s3, 3
	li $s2, 2
	li $s1, 1
	li $s5, 0

	convertString:
	lb $s4, 0($a0)
	beqz $s4, displaySum
	beq $s4, $t1, displaySum
	slti $t6, $s4, 58
	bne $t6, $zero, zeroToNine
	slti $t6, $s4, 89
	bne $t6, $zero, AToX #converts between the string and the number you are looking for
	slti $t6, $s4, 121
	bne $t6, $zero, aTox

	zeroToNine:
	addi $s4, $s4, -48
	j nextStep
	
	AToX: #conversion for the first part
	addi $s4, $s4, -55
	j nextStep
	
	#conversion for the second steps
	aTox:
	addi $s4, $s4, -87
	
	nextStep:
	beq $s0, $s3, cubed
	beq $s0, $s2, squared
	beq $s0, $s1, times_one
	beq $s0, $s5, one

	cubed:
	li $s6, 32768
	mult $s4, $s6
	mflo $s7 # take from the lo -> s7 regsiter because of overfollow 
	add $t7, $t7, $s7
	addi $s0, $s0, -1
	addi $a0, $a0, 1
	j convertString

	squared:
	li $s6, 1024
	mult $s4, $s6
	mflo $s7
	add $t7, $t7, $s7
	addi $s0, $s0, -1
	addi $a0, $a0, 1
	j convertString

	times_one:
	li $s6, 32
	mult $s4, $s6
	mflo $s7
	add $t7, $t7, $s7
	addi $s0, $s0, -1
	addi $a0, $a0, 1
	j convertString

	one:
	li $s6, 1
	mult $s4, $s6
	mflo $s7
	add $t7, $t7, $s7

	displaySum:
	li $v0, 1
	move $a0, $t7
	syscall

	exit:
	li $v0, 10
	syscall
	
.globl findLength
findLength:
	subu $sp,$sp,54 #50 for the .space, and 4 for the length of the string
	sw $ra, ($sp) #store return address
	sw $s0, 4($sp) # store word at the the first index
	
	g
	