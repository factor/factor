# Clang PPC32 uses a hidden complex-double result, GPR complex-float
# results, and by-reference aggregate parameters. The small integer
# aggregate result remains a value in r3.
.text
.macro begin name
.globl \name
.type \name,@function
\name:
 mflr 0
 stw 0,4(1)
 stwu 1,-64(1)
 stw 31,60(1)
 mr 31,3
.endm
.macro end name
 lwz 31,60(1)
 addi 1,1,64
 lwz 0,4(1)
 mtlr 0
 blr
.size \name,.-\name
.endm
begin probe_cd
 bl cd

end probe_cd
begin probe_cf
 bl cf
 stw 3,0(31)
 stw 4,4(31)
end probe_cf
.globl probe_args
.type probe_args,@function
probe_args:
 lwz 7,0(4)
 stw 7,0(3)
 lwz 7,4(4)
 stw 7,4(3)
 lwz 7,8(4)
 stw 7,8(3)
 lwz 7,12(4)
 stw 7,12(3)
 lwz 7,0(5)
 stw 7,16(3)
 lwz 7,4(5)
 stw 7,20(3)
 stw 6,24(3)
 blr
.size probe_args,.-probe_args
begin probe_small
 bl small
 stw 3,0(31)
end probe_small
.globl probe_small_arg
.type probe_small_arg,@function
probe_small_arg:
 lwz 6,0(4)
 add 6,6,5
 stw 6,0(3)
 blr
.size probe_small_arg,.-probe_small_arg
begin probe_bytes3
 bl bytes3
 stw 3,0(31)
end probe_bytes3
begin probe_bytes5
 bl bytes5
 stw 3,0(31)
 stw 4,4(31)
end probe_bytes5
.globl probe_pair
.type probe_pair,@function
probe_pair:
 stw 5,0(3)
 stw 6,4(3)
 stw 7,8(3)
 blr
.size probe_pair,.-probe_pair
.globl probe_stack_pair
.type probe_stack_pair,@function
probe_stack_pair:
 lwz 4,16(1)
 lwz 5,20(1)
 lwz 6,8(1)
 stw 4,0(3)
 stw 5,4(3)
 stw 6,8(3)
 blr
.size probe_stack_pair,.-probe_stack_pair
.section .note.GNU-stack,"",@progbits
