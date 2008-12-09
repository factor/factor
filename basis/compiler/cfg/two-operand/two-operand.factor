! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays kernel sequences compiler.utilities
compiler.cfg.instructions cpu.architecture ;
IN: compiler.cfg.two-operand

! On x86, instructions take the form x = x op y
! Our SSA IR is x = y op z

! We don't bother with ##add, ##add-imm or ##sub-imm since x86
! has a LEA instruction which is effectively a three-operand
! addition

: make-copy ( dst src -- insn ) f \ ##copy boa ; inline

: make-copy/float ( dst src -- insn ) f \ ##copy-float boa ; inline

: convert-two-operand/integer ( insn -- insns )
    [ [ dst>> ] [ src1>> ] bi make-copy ]
    [ dup dst>> >>src1 ]
    bi 2array ; inline

: convert-two-operand/float ( insn -- insns )
    [ [ dst>> ] [ src1>> ] bi make-copy/float ]
    [ dup dst>> >>src1 ]
    bi 2array ; inline

GENERIC: convert-two-operand* ( insn -- insns )

M: ##not convert-two-operand*
    [ [ dst>> ] [ src>> ] bi make-copy ]
    [ dup dst>> >>src ]
    bi 2array ;

M: ##sub convert-two-operand* convert-two-operand/integer ;
M: ##mul convert-two-operand* convert-two-operand/integer ;
M: ##mul-imm convert-two-operand* convert-two-operand/integer ;
M: ##and convert-two-operand* convert-two-operand/integer ;
M: ##and-imm convert-two-operand* convert-two-operand/integer ;
M: ##or convert-two-operand* convert-two-operand/integer ;
M: ##or-imm convert-two-operand* convert-two-operand/integer ;
M: ##xor convert-two-operand* convert-two-operand/integer ;
M: ##xor-imm convert-two-operand* convert-two-operand/integer ;
M: ##shl-imm convert-two-operand* convert-two-operand/integer ;
M: ##shr-imm convert-two-operand* convert-two-operand/integer ;
M: ##sar-imm convert-two-operand* convert-two-operand/integer ;

M: ##add-float convert-two-operand* convert-two-operand/float ;
M: ##sub-float convert-two-operand* convert-two-operand/float ;
M: ##mul-float convert-two-operand* convert-two-operand/float ;
M: ##div-float convert-two-operand* convert-two-operand/float ;

M: insn convert-two-operand* ;

: convert-two-operand ( mr -- mr' )
    [
        two-operand? [
            [ convert-two-operand* ] map-flat
        ] when
    ] change-instructions ;
