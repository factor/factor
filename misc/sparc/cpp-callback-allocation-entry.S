/* Model the compiled callback's original native stack-pointer convention. */
.text
.align 4
.global sparc_callback_sret_entry
.type sparc_callback_sret_entry,#function
sparc_callback_sret_entry:
 save %sp,-96,%sp
 ld [%fp+24],%l0
 ld [%l0+64],%l1
 st %i0,[%l1]
 st %i1,[%l1+4]
 add %i0,%i1,%i0
 st %i0,[%l1+8]
 mov %l1,%i0
 ret
 restore
.size sparc_callback_sret_entry,.-sparc_callback_sret_entry
.section .note.GNU-stack,"",@progbits
