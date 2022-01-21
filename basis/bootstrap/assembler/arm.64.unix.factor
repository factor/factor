! Copyright (C) 2020 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: cpu.arm.assembler cpu.arm.assembler.opcodes kernel layouts
parser sequences ;
IN: bootstrap.assembler.arm

! Stack frame
! https://docs.microsoft.com/en-us/cpp/build/arm64-exception-handling?view=vs-2019


! x0	Volatile	Parameter/scratch register 1, result register
! x1-x7	Volatile	Parameter/scratch register 2-8
! x8-x15	Volatile	Scratch registers
! x16-x17	Volatile	Intra-procedure-call scratch registers
! x18	Non-volatile	Platform register: in kernel mode, points to KPCR for the current processor;
!   in user mode, points to TEB
! x19-x28	Non-volatile	Scratch registers
! x29/fp	Non-volatile	Frame pointer
! x30/lr	Non-volatile	Link registers


: stack-frame-size ( -- n ) 4 bootstrap-cells ;
: volatile-regs ( -- seq ) { X0 X1 X2 X3 X4 X5 X6 X7 X8 X9 X10 X11 X12 X13 X14 X15 X16 X17 } ;
: nv-regs ( -- seq ) { X18 X19 X20 X21 X22 X23 X24 X25 X26 X27 X28 X29 X30 } ;


! callee-save = non-volatile aka call-preserved

! x30 is the link register (used to return from subroutines)
! x29 is the frame register
! x19 to x29 are callee-saved
! x18 is the 'platform register', used for some operating-system-specific special purpose,
!   or an additional caller-saved register
! x16 and x17 are the Intra-Procedure-call scratch register
! x9 to x15: used to hold local variables (caller saved)
! x8: used to hold indirect return value address
! x0 to x7: used to hold argument values passed to a subroutine, and also hold
!   results returned from a subroutine


! https://en.wikichip.org/wiki/arm/aarch64
! Generally, X0 through X18 can corrupt while X19-X29 must be preserved
! Register   Role    Requirement
! X0 -  X7   Parameter/result registers   Can Corrupt
! X8         Indirect result location register
! X9 -  X15  Temporary registers
! X16 - X17  Intra-procedure call temporary
! X18        Platform register, otherwise temporary

! X19 - X29    Callee-saved register    Must preserve
! X30    Link Register    Can Corrupt

: arg1 ( -- reg ) X0 ;
: arg2 ( -- reg ) X1 ;
: arg3 ( -- reg ) X2 ;
: arg4 ( -- reg ) X3 ;
: red-zone-size ( -- n ) 16 ;

<< "vocab:bootstrap/assembler/arm.unix.factor" parse-file suffix! >> call
<< "vocab:bootstrap/assembler/arm.64.factor" parse-file suffix! >> call
<< "vocab:bootstrap/assembler/arm.factor" parse-file suffix! >> call
