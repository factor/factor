	.text

	.globl run_toplevel

	.word exception_handler 
	.word 0

run_toplevel:
	ldr pc, _Prun


_Prun:  .word run

	.section .pdata
	.word run_toplevel

	.word 0xc0000002 | (0xFFFFF << 8)

