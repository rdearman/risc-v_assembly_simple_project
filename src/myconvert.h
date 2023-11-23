# myconvert.h
.data
input_zero:
	.string "Binary=00000000\nDecimal=0\nHexadecimal=0x00\n"

dec_n_hex:
	.string "Decimal=%d\nHexadecimal=%X\n"

bin_string:
	.string "Binary=%s\n"

bstr:
	.space 66 # create an empty array for string

error_args:	.string "No values to parse.\nUsage: myconvert [0b11111111, 0xFF, 255]"
	
.ER0: .string "%s\n"	

	  
