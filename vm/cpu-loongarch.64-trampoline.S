.text
.p2align 2
.global trampoline
.type trampoline,@function
trampoline:
  addi.d $sp, $sp, -16
  st.d $fp, $sp, 0
  st.d $ra, $sp, 8
  or $fp, $sp, $zero
  st.d $fp, $s2, 0
  jirl $ra, $t2, 0
  ld.d $fp, $sp, 0
  ld.d $ra, $sp, 8
  addi.d $sp, $sp, 16
  jirl $zero, $ra, 0
.size trampoline,.-trampoline
.global trampoline2
.type trampoline2,@function
trampoline2:
  st.d $fp, $t3, 0
  st.d $ra, $t3, 8
  or $fp, $t3, $zero
  st.d $fp, $s2, 0
  jirl $ra, $t2, 0
  ld.d $ra, $fp, 8
  ld.d $fp, $fp, 0
  jirl $zero, $ra, 0
.size trampoline2,.-trampoline2
.section .note.GNU-stack,"",@progbits
