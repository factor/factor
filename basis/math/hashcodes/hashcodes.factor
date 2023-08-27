! Copyright (C) 2013 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: combinators kernel layouts math math.bitwise
math.floating-point math.functions ;

IN: math.hashcodes

GENERIC: number-hashcode ( x -- h )

<PRIVATE

: P ( -- x )
    cell-bits 64 = 61 31 ? 2^ 1 - ; inline foldable

: M ( -- x )
    cell-bits 1 - 2^ ; inline foldable

: hash-fraction ( m n -- h )

    [ 2dup [ P mod zero? ] both? ] [
        [ P /i ] bi@
    ] while

    dup P mod zero? [
        2drop 1/0.
    ] [
        over [
            [ abs P mod ] [ P 2 - P ^mod P mod ] bi* *
        ] dip 0 < [ neg ] when
        dup -1 = [ drop -2 ] when
    ] if ; inline

PRIVATE>

M: integer number-hashcode 1 hash-fraction ;

M: ratio number-hashcode >fraction hash-fraction ;

M: float number-hashcode
    {
        { [ dup fp-nan? ] [ drop 0 ] }
        { [ dup fp-infinity? ] [ 0 > 314159 -314159 ? ] }
        [ double>ratio number-hashcode ]
    } cond ;

M: complex number-hashcode
    >rect [ number-hashcode ] bi@ 1000003 * +
    cell-bits on-bits bitand dup -1 = [ drop -2 ] when ;
