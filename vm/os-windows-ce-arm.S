	.text

	.globl run_toplevel

	.word exception_handler
	.word 0

c_to_factor_toplevel:
	ldr pc, _Pc_to_factor


_Pc_to_factor:
	.word c_to_factor

	.section .pdata
	.word c_to_factor_toplevel

	.word 0xc0000002 | (0xFFFFF << 8)

