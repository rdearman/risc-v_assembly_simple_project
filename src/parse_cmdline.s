# parse_cmdline.s
.include "myconvert.h"
	
.text
.globl parse_cmdline

parse:
	lw      a5, -20(s0)	# Load the loop counter into a5
	slli    a5, a5, 3       # Multiply the loop counter by 8 (size of a pointer)
	ld      a4, -48(s0)     # Load the address of argv into a4

	add     a5, a4, a5      # Calculate the address of argv[i]
	ld 	a5, 0(a5)	# Load the value at argv[i] into a5
	lb      a6, 0(a5)       # Load the byte at argv[i] into a6 (assuming it's a character)
	lb	a7, 1(a5)	# load the next byte into a7  (assuming it's a character)
	li      t1, 48             # ASCII value for '0'
	li      t2, 120            # ASCII value for 'x'
	li      t3, 98             # ASCII value for 'b'
	li      t4, 57             # ASCII value for '9'	
	# check for integer values!
	blt 	a6, t1, not_between
	bgt	a6, t4, not_between
	beq	a6, t1, not_between # just add in zero here, because should have a decimal strting with zero
	# They passed a decimal, so need to change the string to integer
	# Assuming a6 contains the first character of the string
	# Assuming a3 is the register to store the final integer result
	# Initialize a3 to zero
	li      a3, 0

decimal_convert_loop:
	# Check if the current character is the null terminator (end of the string)
	beqz    a6, decimal_end_conversion

	# Convert ASCII character to integer ('0' has ASCII value 48)
	li      t1, 48
	sub     a6, a6, t1

	# Multiply the current result by 10
	li 	t0, 10
	mul     a3, a3, t0

	# Add the current digit to the result
	add     a3, a3, a6

	# Load the next character in the string
	addi    a5, a5, 1
	lb      a6, 0(a5)

	# Repeat the loop
	j       decimal_convert_loop

decimal_end_conversion:
	# Now a3 contains the converted integer value
	mv 	a5, a3
	jal 	build_binary_string
	mv 	a5, a3	
	j	output_result

not_between:	
	# not a decimal integer, so check for empty string, or hex, or binary
	# Check if the loaded character is null, 'x', or 'b'
	beq     a6, x0, null_char  # Check for null character
	beq     a7, t2, is_x       # Check for 'x'
	beq     a7, t3, is_b       # Check for 'b'

	# If none of the above conditions are met, it is not null, 'x', or 'b'
	# and not a decimal, then end this loop
	j	end_of_loop
	
null_char:
	# Code for null character case means end of string
	j 	end_of_loop

is_x:
	# Initialize a3 to 0
	li      a3, 0

start_conversion:
	addi    a5, a5, 2  # Skip 2 characters along
	lbu     a4, 0(a5)  # Load the second character of the string into a4

	# Mask the upper bits to handle only 32-bit hexadecimal values
	slli    t6, a4, 0        # Shift left by 0 bits (no shift)
	srli    a4, t6, 0        # Shift right by 0 bits (no shift)

	
convert_char_to_int:
	beqz    a4, end_conversion  # Check for the end of the string (null terminator)
	li      t1, 48               # ASCII value for '0'
	li      t2, 58               # ASCII value for '9' + 1
	li      t3, 65               # ASCII value for 'A'
	li      t4, 71               # ASCII value for 'F' + 1
	li      t5, 96               # ASCII value for 'a' - 1

	blt     a4, t2, numeric_char
	blt     a4, t4, non_numeric_uppercase
	bgt     a4, t5, non_numeric_lowercase

numeric_char:
	sub     a4, a4, t1           # Convert ASCII to numeric value
	j       update_result

non_numeric_uppercase:
	blt     a4, t3, non_numeric_lowercase
	addi    a4, a4, -55           # Convert ASCII to numeric value for A-F
	j       update_result

non_numeric_lowercase:
	addi    a4, a4, -87           # Convert ASCII to numeric value for a-f

update_result:
	slli    a3, a3, 4            # Shift current result left by 4 bits
	slli    a4, a4, 56           # Shift left to zero-extend ASCII character to 64 bits
	srli    a4, a4, 56           # Shift right to remove upper bits
	or      a3, a3, a4           # Add the new nibble to the result
	addi    a5, a5, 1            # Move to the next character in the string
	lbu     a4, 0(a5)             # Load the next character value into a4
	j       convert_char_to_int
	
end_conversion:
	# Now a3 contains the converted integer value
	j       end_of_loop

is_b:
	# Initialize a3 to 0
	li      a3, 0
	j binary_start_conversion
	
binary_start_conversion:
	addi    a5, a5, 2  # Skip 2 characters along (assuming the prefix "0b" is present)
	lbu     a4, 0(a5)  # Load the first character of the binary string into a4

binary_convert_char_to_int:
	beqz    a4, end_conversion  # Check for the end of the string (null terminator)
	li      t1, 48               # ASCII value for '0'
	li      t2, 49               # ASCII value for '1'
    
	blt     a4, t1, end_of_loop
	bgt     a4, t2, end_of_loop

	# Convert ASCII character to binary value ('0' has ASCII value 48, '1' has ASCII value 49)
	sub     a4, a4, t1

	# Multiply the current result by 2
	slli    a3, a3, 1

	# Add the current digit to the result
	add     a3, a3, a4

	# Load the next character in the string
	addi    a5, a5, 1
	lbu     a4, 0(a5)

	# Repeat the loop
	j       convert_char_to_int

end_of_loop:
	# Continue with the rest of loop logic
	lw      a6, -20(s0)        # Load the loop counter into a6
	addiw   a6, a6, 1          # Increment the loop counter
	sw      a6, -20(s0)        # Store the updated loop counter
	sw      a3, -62(s0)        # Store the updated integer
	j 	parse_cmdline      # Jump back to the beginning of the loop
	
parse_cmdline:
	lw      a5, -20(s0)              # Load the loop counter into a5
	mv      a4, a5                   # Move the loop counter to a4
	sw      a4, -20(s0)        	 # Store the updated loop counter
	lw      a5, -36(s0)              # Load argc into a5
	sext.w  a4, a4                   # Sign-extend a4
	sext.w  a5, a5                   # Sign-extend a5
	
	blt     a4, a5, parse            # Branch to parse if a4 < a5 (loop condition)
	li      a5, 0                    # Load immediate value 0 into a5
	
	# Adjust s0 to point to the beginning of the allocated stack space
	addi    s0, sp, 0
	
	mv      a0, a5                   # Move the value in a5 to a0
	ld      ra, 56(sp)               # Load the return address from the stack into ra
	ld      s0, 48(sp)               # Load s0 from the stack
	addi    sp, sp, -64              # Adjust the stack pointer to deallocate the stack space
	sd      a3, 62(sp)               # Store the number into the stack
	mv 	a5, a3
	beq	a5, x0, zero_input	# if the integer is zero, just print standard zero message
	jal 	build_binary_string
	ld      a5, 62(sp) 
	jal	output_result
