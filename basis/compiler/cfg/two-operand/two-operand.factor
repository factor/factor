! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel sequences make combinators
compiler.cfg.registers compiler.cfg.instructions
compiler.cfg.rpo cpu.architecture ;
IN: compiler.cfg.two-operand

! This pass runs before SSA coalescing and normalizes instructions
! to fit the x86 two-address scheme. Since the input is in SSA,
! it suffices to convert
!
! x = y op z
!
! to
!
! x = y
! x = x op z
!
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
    ##min
    ##max
    ##fixnum-add
    ##fixnum-sub
    ##fixnum-mul
    ##add-float
    ##sub-float
    ##mul-float
    ##div-float
    ##min-float
    ##max-float
    ##add-vector
    ##saturated-add-vector
    ##add-sub-vector
    ##sub-vector
    ##saturated-sub-vector
    ##mul-vector
    ##saturated-mul-vector
    ##div-vector
    ##min-vector
    ##max-vector
    ##and-vector
    ##or-vector
    ##xor-vector ;

GENERIC: convert-two-operand* ( insn -- )

: emit-copy ( dst src -- )
    dup rep-of ##copy ; inline

M: two-operand-insn convert-two-operand*
    [ [ dst>> ] [ src1>> ] bi emit-copy ]
    [
        dup [ src1>> ] [ src2>> ] bi = [ dup dst>> >>src2 ] when
        dup dst>> >>src1 ,
    ] bi ;

M: ##not convert-two-operand*
    [ [ dst>> ] [ src>> ] bi emit-copy ]
    [ dup dst>> >>src , ]
    bi ;

M: insn convert-two-operand* , ;

: (convert-two-operand) ( insns -- insns' )
    dup first kill-vreg-insn? [
        [ [ convert-two-operand* ] each ] V{ } make
    ] unless ;

: convert-two-operand ( cfg -- cfg' )
    two-operand? [ [ (convert-two-operand) ] local-optimization ] when ;