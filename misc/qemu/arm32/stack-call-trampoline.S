.syntax unified
.arm
.text
.global tramp2
.type tramp2,%function
tramp2:
str fp,[r4]
str lr,[r4,#4]
mov fp,r4
str fp,[r8]
blx ip
ldr lr,[fp,#4]
ldr fp,[fp]
bx lr
.section .note.GNU-stack,"",%progbits
