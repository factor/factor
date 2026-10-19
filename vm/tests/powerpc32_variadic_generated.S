# MARKER must name the four-byte output of powerpc32_variadic_marker.factor.
#ifndef MARKER
#error Define MARKER as the generated marker file path
#endif
.text
.globl invoke_generated
.type invoke_generated,@function
invoke_generated:
 mflr 0
 stw 0,4(1)
 stwu 1,-16(1)
.incbin MARKER
 bl read_variadic
 addi 1,1,16
 lwz 0,4(1)
 mtlr 0
 blr
.size invoke_generated,.-invoke_generated
.section .note.GNU-stack,"",@progbits
