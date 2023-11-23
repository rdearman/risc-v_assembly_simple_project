# main.s
.include "myconvert.h"

.text
.globl main
.globl error_message
.globl zero_input
	
error_message:
	la a0, .ER0
	mv a1, a4
	call printf@plt
	j exit
	
	
wrong_args:
	# Set up arguments for printf	
	la a0, error_args	# Load the address of the format string
	call printf@plt    	# Use "printf" for formatted output
	j exit

zero_input:	
	# Set up arguments for printf	
	la a0, input_zero	# Load the address of the format string
	call printf@plt    	# Use "printf" for formatted output
	j exit

	
main:
	li      t6, 2                   # Used to check the number of arguments.
	addi    t0, sp, -64              # Calculate the new stack pointer value with 16-byte alignment
	andi    sp, t0, -16              # Align the stack pointer
	sd      ra, 56(sp)               # Store the return address (ra) on the stack
	sd      s0, 48(sp)               # Store s0 on the stack
	addi    s0, sp, 64               # Adjust s0 to point to the end of the allocated stack space
	mv      a5, a0                   # Move the value in a0 (argc) to a5
	sd      a1, -48(s0)              # Store a1 (argv) on the stack at offset -48 from s0
	sw      a5, -36(s0)              # Store the value of a5 on the stack at offset -36 from s0
	lw      a5, -36(s0)              # Load the value at offset -36 from s0 into a5
	mv      a1, a5                   # Move the value in a5 to a1
	blt     a1, t6, wrong_args      # Not enough arguments.
	li 	t1, 1			# loop counter starting value
	sw      t1, -20(s0)              # Initialize a loop counter to 1
	jal     parse_cmdline           # Jump to the beginning of the loop
	j 	exit
	
exit:
	li a0, 0
	li a7, 93
	ecall



