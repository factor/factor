.text
.macro begin name
.globl \name
.type \name,@function
\name:
 mflr 0
 std 0,16(1)
 stdu 1,-128(1)
 std 31,120(1)
 mr 31,3
.endm
.macro end name
 ld 31,120(1)
 addi 1,1,128
 ld 0,16(1)
 mtlr 0
 blr
.size \name,.-\name
.endm
begin probe_pair
 bl abi_pair
 nop
 std 3,0(31)
 std 4,8(31)
end probe_pair
begin probe_hfa
 bl abi_hfa
 nop
 stfs 1,0(31)
 stfs 2,4(31)
 stfs 3,8(31)
 stfs 4,12(31)
 stfs 5,16(31)
 stfs 6,20(31)
 stfs 7,24(31)
 stfs 8,28(31)
end probe_hfa
.section .note.GNU-stack,"",@progbits
