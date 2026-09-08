! Copyright (C) 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors compiler.cfg.instructions
compiler.cfg.value-numbering.graph
compiler.cfg.value-numbering.rewrite kernel layouts locals math
math.bitwise math.order ;
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
    ! Machine arithmetic wraps at the target width, even though the
    ! compiler evaluates it with arbitrary-precision Factor integers.
    cell-bits >signed ##load-integer new-insn ; inline

GENERIC: unary-constant-fold? ( insn -- ? )

M: insn unary-constant-fold?
    src>> vreg>insn ##load-integer? ;

M: ##integer>float unary-constant-fold?
    ! Inexact conversions must honor runtime rounding modes and exception flags.
    dup call-next-method [
        src>> vreg>integer abs 0x20000000000000 <=
    ] [ drop f ] if ;

GENERIC: unary-constant-fold* ( x insn -- y )

M: ##not unary-constant-fold* drop bitnot ;
M: ##neg unary-constant-fold* drop neg ;
M: ##integer>float unary-constant-fold* drop >float ;

: unary-constant-fold ( insn -- insn' )
    [ dst>> ] [ [ src>> vreg>integer ] [ ] bi unary-constant-fold* ] bi
    dup float?
    [ ##load-reference new-insn ]
    [ cell-bits >signed ##load-integer new-insn ] if ; inline

:: exact-single? ( x -- ? )
    ! Check the binary64 encoding without performing a narrowing conversion.
    ! Keep subnormals and NaNs at runtime: denormal modes and signaling NaN
    ! behavior can affect their conversion even when rounding is exact.
    x double>bits 0x7fffffffffffffff bitand :> encoding
    encoding 0 = encoding 0x7ff0000000000000 = or [ t ] [
        encoding -52 shift 1023 - -126 127 between?
        encoding 29 bits zero? and
    ] if ;
