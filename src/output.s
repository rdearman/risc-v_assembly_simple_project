# output
.include "myconvert.h"

.text
.globl output_result
.globl build_binary_string

	
output_result:
	# Decrement the stack pointer to allocate space for one word (4 bytes).
	addi 	sp, sp, -4
	# Store the values from the ra and a5 registers onto the stack. The
	# printf function blows away the 'a' registers so we have to save
	# the ones we need for the second printf statement. 
	sw 	ra, 0(sp)
	sw 	a5, 4(sp) 

	# Set up arguments for printf	
	la 	a0, bin_string # Load the address of the format string
	la 	t0, bstr       # Move the pointer to the string 
	mv 	a1, t0         # put the pointer address into the argument register
	call 	printf@plt    # Use "printf" for formatted output

	# Restore original values from the stack which printf blew away
	lw 	a5, 4(sp)
	lw 	ra, 0(sp)

	# Set up arguments for 2nd printf
	la 	a0, dec_n_hex   # Load the address of the format string
	mv 	a1, a5          # Move the value in a5 to a1 (integer to print)
	mv 	a2, a5          # Move the value in a5 to a2 (hex to print)  
	call 	printf@plt    # Use "printf" for formatted output
	
	# Load the value from the stack into ra.
	lw 	ra, 0(sp)
	# Increment the stack pointer to release the allocated space.
	addi 	sp, sp, 4
	j 	exit # quit
	

build_binary_string:
	# Initialize variables
	# This section initializes the variables. t0 is set to 64, representing the
	# maximum length of the binary string, and t1 is loaded with the address of
	# the bstr buffer where the binary string will be stored.
	li  	t0, 64           # Set t0 to 64 for the maximum length of the binary string
	la  	t1, bstr         # Load the address of bstr into t1

	# Loop to convert the number to binary string
convert_loop:
	# Check if the number is zero or the string is full
	beqz 	a5, end_convert
	beqz 	t0, end_convert

	srai 	a6, a5, 1	# Shift the number to the right

	# Convert the least significant bit to ASCII '0' or '1'
	and 	t2, a5, 1
	addi 	t2, t2, '0'
	sb 	t2, 0(t1) 	# Store the character in the string
	addi 	t1, t1, 1	# Move to the next character in the string
	addi 	t0, t0, -1	# Decrement the counter
	mv 	a5, a6	# Update a5 with the shifted value

	# Repeat the loop
	j 	convert_loop

end_convert:
	# Null-terminate the string
	sb 	zero, 0(t1)
	ret
