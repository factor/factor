.abiversion 2
.text
.align 2
.globl ppc64_signal_register_fault
.type ppc64_signal_register_fault,@function
ppc64_signal_register_fault:
 mflr 0
 std 0,16(1)
 std 2,24(1)
 std 0,24(4)
 stdu 1,-96(1)
 std 1,16(4)
 lis 12,0x1234
 ori 12,12,0x5678
 lis 2,0x2345
 ori 2,2,0x6789
.globl ppc64_signal_fault_pc
ppc64_signal_fault_pc:
 ld 0,0(3)
 std 12,0(4)
 std 2,8(4)
 addi 1,1,96
 ld 0,16(1)
 ld 2,24(1)
 mtlr 0
 blr
.size ppc64_signal_register_fault,.-ppc64_signal_register_fault
.section .note.GNU-stack,"",@progbits
