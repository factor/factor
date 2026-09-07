! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel locals math math.bitwise math.floating-point ;
IN: math.floats.small.bfloat

! Reference for Arm's baseline BFDotAdd/BFMatMulAddH semantics (FPCR.EBF=0).
! All intermediate products and sums round to odd in binary32 and flush
! subnormals. Exact rational arithmetic preserves sticky bits across large
! exponent differences, including differences too large for binary64.
<PRIVATE
: rational-power-of-two ( exponent -- value )
    dup 0 < [ neg 2^ recip ] [ 2^ ] if ;

:: round-bfloat-intermediate ( exact -- value )
    exact 0 < 0x80000000 0 ? :> sign
    exact abs :> magnitude
    magnitude zero? [ sign bits>float ] [
        magnitude numerator log2 magnitude denominator log2 - :> exponent!
        magnitude exponent rational-power-of-two < [ exponent 1 - exponent! ] when
        exponent -126 < [ sign bits>float ] [
            exponent 128 >= [ sign 0x7f800000 bitor bits>float ] [
                magnitude 23 exponent - rational-power-of-two * :> scaled
                scaled >integer :> significand
                scaled significand = [ significand ] [ significand 1 bitor ] if
                0x7fffff bitand exponent 127 + 23 shift bitor sign bitor bits>float
            ] if
        ] if
    ] if ;

: flush-bfloat-input ( value -- value' )
    dup float>bits 0x7f800000 bitand zero?
    [ float>bits 0x80000000 bitand bits>float ] when ;
: canonical-bfloat-nan ( value -- value' )
    dup dup unordered? [ drop 0x7fc00000 bits>float ] when ;
PRIVATE>

:: bfloat-product ( x y -- value )
    x flush-bfloat-input :> a
    y flush-bfloat-input :> b
    a fp-special? b fp-special? or [ a b * canonical-bfloat-nan ] [
        a zero? b zero? or
        [ a float>bits b float>bits bitxor 0x80000000 bitand bits>float ]
        [ a double>ratio b double>ratio * round-bfloat-intermediate ] if
    ] if ;

:: bfloat-add ( x y -- value )
    x flush-bfloat-input :> a
    y flush-bfloat-input :> b
    a fp-special? b fp-special? or [ a b + canonical-bfloat-nan ] [
        a zero? b zero? and
        [ a float>bits b float>bits bitand 0x80000000 bitand bits>float ]
        [ a double>ratio b double>ratio + round-bfloat-intermediate ] if
    ] if ;

:: bfloat-dot-add ( accumulator a0 a1 b0 b1 -- result )
    accumulator a0 b0 bfloat-product a1 b1 bfloat-product bfloat-add bfloat-add ;
