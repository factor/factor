.syntax unified
.text
.arm
.p2align 2
.global arm32_fault_arm
.type arm32_fault_arm,%function
arm32_fault_arm:
  udf #0
  bx lr
.size arm32_fault_arm,.-arm32_fault_arm
.global arm32_entry_arm
.type arm32_entry_arm,%function
arm32_entry_arm:
  bx lr
.size arm32_entry_arm,.-arm32_entry_arm
.thumb
.p2align 1
.global arm32_fault_thumb
.type arm32_fault_thumb,%function
.thumb_func
arm32_fault_thumb:
  udf #0
  bx lr
.size arm32_fault_thumb,.-arm32_fault_thumb
.global arm32_entry_thumb
.type arm32_entry_thumb,%function
.thumb_func
arm32_entry_thumb:
  bx lr
.size arm32_entry_thumb,.-arm32_entry_thumb
.section .note.GNU-stack,"",%progbits
