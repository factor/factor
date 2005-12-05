IN: compiler-backend
USING: assembler compiler-backend kernel math ;

! PowerPC register assignments
! r3-r10 vregs
! r14 data stack
! r15 call stack

: fixnum-imm? ( -- ? )
    #! Can fixnum operations take immediate operands?
    f ; inline

: vregs { 3 4 5 6 7 8 9 10 } ; inline

M: int-regs fastcall-regs drop 8 ;
M: int-regs reg-class-size drop 4 ;
M: float-regs fastcall-regs drop 8 ;

! Mach-O -vs- Linux/PPC
: stack@ os "macosx" = 24 8 ? + ;
: lr@ os "macosx" = 8 4 ? + ;
: dual-fp/int-regs? os "macosx" = ;
