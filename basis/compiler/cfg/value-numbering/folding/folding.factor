! Copyright (C) 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors compiler.cfg.instructions
compiler.cfg.value-numbering.graph
compiler.cfg.value-numbering.rewrite kernel layouts math
math.bitwise ;
IN: compiler.cfg.value-numbering.folding

: binary-constant-fold? ( insn -- ? )
    src1>> vreg>insn ##load-integer? ; inline

GENERIC: binary-constant-fold* ( x y insn -- z )

M: ##add-imm binary-constant-fold* drop + ;
M: ##sub-imm binary-constant-fold* drop - ;
M: ##mul-imm binary-constant-fold* drop * ;
M: ##and-imm binary-constant-fold* drop bitand ;
M: ##or-imm binary-constant-fold* drop bitor ;
M: ##xor-imm binary-constant-fold* drop bitxor ;
M: ##shr-imm binary-constant-fold* drop [ cell-bits 2^ wrap ] dip neg shift ;
M: ##sar-imm binary-constant-fold* drop neg shift ;
M: ##shl-imm binary-constant-fold* drop shift ;

: binary-constant-fold ( insn -- insn' )
    [ dst>> ]
    [ [ src1>> vreg>integer ] [ src2>> ] [ ] tri binary-constant-fold* ] bi
    ##load-integer new-insn ; inline

: unary-constant-fold? ( insn -- ? )
    src>> vreg>insn ##load-integer? ; inline

GENERIC: unary-constant-fold* ( x insn -- y )

M: ##not unary-constant-fold* drop bitnot ;
M: ##neg unary-constant-fold* drop neg ;

: unary-constant-fold ( insn -- insn' )
    [ dst>> ] [ [ src>> vreg>integer ] [ ] bi unary-constant-fold* ] bi
    ##load-integer new-insn ; inline
