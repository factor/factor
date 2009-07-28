! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel sequences make combinators
compiler.cfg.registers compiler.cfg.instructions
compiler.cfg.rpo cpu.architecture ;
IN: compiler.cfg.two-operand

! This pass runs after SSA coalescing and normalizes instructions
! to fit the x86 two-address scheme. Possibilities are:

! 1) x = x op y
! 2) x = y op x
! 3) x = y op z

! In case 1, there is nothing to do.

! In case 2, we convert to
! z = y
! z = z op x
! x = z

! In case 3, we convert to
! x = y
! x = x op z

! In case 2 and case 3, linear scan coalescing will eliminate a
! copy if the value y is never used again.

! We don't bother with ##add, ##add-imm, ##sub-imm or ##mul-imm
! since x86 has LEA and IMUL instructions which are effectively
! three-operand addition and multiplication, respectively.

UNION: two-operand-insn
    ##sub
    ##mul
    ##and
    ##and-imm
    ##or
    ##or-imm
    ##xor
    ##xor-imm
    ##shl
    ##shl-imm
    ##shr
    ##shr-imm
    ##sar
    ##sar-imm
    ##fixnum-overflow
    ##add-float
    ##sub-float
    ##mul-float
    ##div-float ;

GENERIC: convert-two-operand* ( insn -- )

: emit-copy ( dst src -- )
    dup reg-class>> {
        { int-regs [ ##copy ] }
        { double-float-regs [ ##copy-float ] }
    } case ; inline

: case-1? ( insn -- ? ) [ dst>> ] [ src1>> ] bi = ; inline

: case-1 ( insn -- ) , ; inline

: case-2? ( insn -- ? ) [ dst>> ] [ src2>> ] bi = ; inline

ERROR: bad-case-2 insn ;

: case-2 ( insn -- )
    ! This can't work with a ##fixnum-overflow since it branches
    dup ##fixnum-overflow? [ bad-case-2 ] when
    dup dst>> reg-class>> next-vreg
    [ swap src1>> emit-copy ]
    [ [ >>src1 ] [ >>dst ] bi , ]
    [ [ src2>> ] dip emit-copy ]
    2tri ; inline

: case-3 ( insn -- )
    [ [ dst>> ] [ src1>> ] bi emit-copy ]
    [ dup dst>> >>src1 , ]
    bi ; inline

M: two-operand-insn convert-two-operand*
    {
        { [ dup case-1? ] [ case-1 ] }
        { [ dup case-2? ] [ case-2 ] }
        [ case-3 ]
    } cond ; inline

M: ##not convert-two-operand*
    dup [ dst>> ] [ src>> ] bi = [
        [ [ dst>> ] [ src>> ] bi ##copy ]
        [ dup dst>> >>src ]
        bi
    ] unless , ;

M: insn convert-two-operand* , ;

: (convert-two-operand) ( cfg -- cfg' )
    [ [ convert-two-operand* ] each ] V{ } make ;

: convert-two-operand ( cfg -- cfg' )
    two-operand? [ [ (convert-two-operand) ] local-optimization ] when ;