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
 stw 3,0(31)
 stw 4,4(31)
 stw 5,8(31)
 stw 6,12(31)
end probe_cd
begin probe_cf
 bl cf
 stw 3,0(31)
 stw 4,4(31)
end probe_cf
.globl probe_args
.type probe_args,@function
probe_args:
 stw 4,0(3)
 stw 5,4(3)
 stw 6,8(3)
 stw 7,12(3)
 stw 9,16(3)
 stw 10,20(3)
 lwz 0,8(1)
 stw 0,24(3)
 blr
.size probe_args,.-probe_args
.section .note.GNU-stack,"",@progbits
