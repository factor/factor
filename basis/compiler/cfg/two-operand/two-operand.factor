! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays kernel sequences make compiler.cfg.instructions
compiler.cfg.rpo cpu.architecture ;
IN: compiler.cfg.two-operand

! On x86, instructions take the form x = x op y
! Our SSA IR is x = y op z

! We don't bother with ##add, ##add-imm or ##sub-imm since x86
! has a LEA instruction which is effectively a three-operand
! addition

: make-copy ( dst src -- insn ) \ ##copy new-insn ; inline

: make-copy/float ( dst src -- insn ) \ ##copy-float new-insn ; inline

: convert-two-operand/integer ( insn -- insns )
    [ [ dst>> ] [ src1>> ] bi ##copy ]
    [ dup dst>> >>src1 , ]
    bi ; inline

: convert-two-operand/float ( insn -- insns )
    [ [ dst>> ] [ src1>> ] bi ##copy-float ]
    [ dup dst>> >>src1 , ]
    bi ; inline

GENERIC: convert-two-operand* ( insn -- )

M: ##not convert-two-operand*
    [ [ dst>> ] [ src>> ] bi ##copy ]
    [ dup dst>> >>src , ]
    bi ;

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

M: insn convert-two-operand* , ;

: convert-two-operand ( cfg -- cfg' )
    two-operand? [
        dup [
            [
                [ [ convert-two-operand* ] each ] V{ } make
            ] change-instructions drop
        ] each-basic-block
    ] when ;
