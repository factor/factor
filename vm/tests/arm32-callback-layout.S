.syntax unified
.arm
.fpu vfpv3-d16
.text
.macro save_header
 vpush {d8-d15}
 sub sp,sp,#48
 stmia sp,{r4-r11}
 str lr,[sp,#32]
.endm
.macro restore_header
 ldr lr,[sp,#32]
 ldmia sp,{r4-r11}
 add sp,sp,#48
 vpop {d8-d15}
.endm
.global callback_layout
.type callback_layout,%function
callback_layout:
 save_header
 ldr r0,[sp,#112]
 bl clobber_callback
 restore_header
 bx lr
.global callback_varargs_layout
.type callback_varargs_layout,%function
callback_varargs_layout:
 push {r0-r3}
 save_header
 ldr r0,[sp,#112]
 ldr r1,[sp,#128]
 add r0,r0,r1
 bl clobber_callback
 restore_header
 add sp,sp,#16
 bx lr
clobber_callback:
 mov r4,#0
 mov r5,#0
 mov r6,#0
 mov r7,#0
 mov r8,#0
 mov r9,#0
 mov r10,#0
 mov r11,#0
 vmov d8,r4,r5
 vmov d9,r4,r5
 vmov d10,r4,r5
 vmov d11,r4,r5
 vmov d12,r4,r5
 vmov d13,r4,r5
 vmov d14,r4,r5
 vmov d15,r4,r5
 bx lr
.section .note.GNU-stack,"",%progbits
