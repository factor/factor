! Copyright (C) 2018 Alexander Ilin.
! See https://factorcode.org/license.txt for BSD license.
USING: combinators.smart kernel math math.bitwise
math.functions math.order math.parser ryu.data sequences
sequences.private ;

IN: ryu

<PRIVATE

: mul-shift ( x mul shift -- y )
    [ first2 rot [ * ] guardd * -64 shift + ] [ 64 - neg ] bi* shift ;

: mul-shift-all ( mmShift m mul shift -- vm vp vr )
    [ 4 * ] 2dip
    [ [ 1 - swap - ] 2dip mul-shift ]
    [ [ 2 +        ] 2dip mul-shift ]
    [                     mul-shift ] 3tri ;

:: pow-5-factor ( x -- y )
    x f 0 [ 2dup x > or ] [
        [ 5 /mod ] 2dip rot zero? [ 1 + ] [ nip dupd ] if
    ] until 2nip ; inline

: multiple-of-power-of-5 ( p value -- ? )
    pow-5-factor <= ;

: double-pow-5-bits ( n -- m )
    [ 1 ] [
        DOUBLE_LOG2_5_NUMERATOR * DOUBLE_LOG2_5_DENOMINATOR + 1 -
        DOUBLE_LOG2_5_DENOMINATOR /i
    ] if-zero ; inline

: decimal-length ( m -- n )
    {
        10
        100
        1000
        10000
        100000
        1000000
        10000000
        100000000
        1000000000
        10000000000
        100000000000
        1000000000000
        10000000000000
        100000000000000
        1000000000000000
        10000000000000000
        100000000000000000
        1000000000000000000
    } [ dupd >= ] find-last [ 2 + ] [ drop 1 ] if nip ; inline

CONSTANT: mantissaBits 52
CONSTANT: exponentBits 11
CONSTANT: offset 1023 ! (1 << (exponentBits - 1)) - 1

:: unpack-bits ( value -- e2 m2 acceptBounds ieeeExponent<=1? neg? string/f )
    value double>bits
    dup mantissaBits exponentBits + bit? :> sign
    dup mantissaBits bits :> ieeeMantissa
    mantissaBits neg shift exponentBits bits :> ieeeExponent
    0 :> m2!
    0 :> e2!
    exponentBits on-bits ieeeExponent = [
        ieeeMantissa zero? [ sign "-Inf" "Inf" ? ] [ "NaN" ] if
    ] [
        ieeeExponent [
            ieeeMantissa [ sign "-0e0" "0e0" ? ] [
                m2!
                -1 offset - mantissaBits - e2!
                f
            ] if-zero
        ] [
            offset - mantissaBits - 2 - e2!
            ieeeMantissa mantissaBits set-bit m2!
            f
        ] if-zero
    ] if [ e2 m2 dup even? ieeeExponent 1 <= sign ] dip ; inline

:: prepare-output ( vp! acceptBounds vmIsTrailingZeros! vrIsTrailingZeros! vr! vm! -- output )
    ! vr is converted into the output
    0
    ! the if has this stack-effect: ( lastRemovedDigit -- lastRemovedDigit' output )
    vmIsTrailingZeros vrIsTrailingZeros or [
        ! rare
        [ vp 10 /i vm 10 /i 2dup > ] [
            vm! vp!
            vmIsTrailingZeros [ vm 10 divisor? vmIsTrailingZeros! ] when
            vrIsTrailingZeros [ dup zero? vrIsTrailingZeros! ] when
            vr 10 /mod swap vr! nip ! lastRemovedDigit!
        ] while 2drop
        vmIsTrailingZeros [
            [ vm dup 10 /i dup 10 * swapd = ] [
                vm!
                vrIsTrailingZeros [ dup zero? vrIsTrailingZeros! ] when
                vr 10 /mod swap vr! nip ! lastRemovedDigit!
                vp 10 /i vp!
            ] while drop ! Drop (vm 10 /i) result from the while condition.
        ] when
        vrIsTrailingZeros [
            dup 5 = [
                vr even? [ drop 4 ] when ! 4 lastRemovedDigit!
            ] when
        ] when
        vr over 5 >= [ 1 + ] [
            dup vm = [
                acceptBounds vmIsTrailingZeros and not [ 1 + ] when
            ] when
        ] if
    ] [
        ! common
        [ vp 10 /i vm 10 /i 2dup > ] [
            vm! vp!
            vr 10 /mod swap vr! nip ! lastRemovedDigit!
        ] while 2drop
        vr dup vm = [ 1 + ] [
            over 5 >= [ 1 + ] when
        ] if
    ] if nip ; inline

:: produce-output ( exp sign output -- string )
    [
        sign "-" f ?
        output number>string 1 cut-slice dup empty? f "." ? swap
        "e"
        exp number>string
    ] "" append-outputs-as ; inline

PRIVATE>

:: print-float ( value -- string )
    value >float unpack-bits
    :> ( e2 m2 acceptBounds ieeeExponent<=1 sign output )
    output [
        m2 4 * :> mv
        mantissaBits 2^ m2 = not ieeeExponent<=1 or 1 0 ? :> mmShift
        f f 0 0 0 :> ( vmIsTrailingZeros! vrIsTrailingZeros! e10! vr! vm! )
        ! After the following loop vp is left on stack.
        e2 0 >= [
            e2 DOUBLE_LOG10_2_NUMERATOR * DOUBLE_LOG10_2_DENOMINATOR /i 0 max :> q
            q e10!
            q double-pow-5-bits DOUBLE_POW5_INV_BITCOUNT + 1 - :> k
            q k + e2 - :> i
            mmShift m2 q DOUBLE_POW5_INV_SPLIT nth-unsafe i mul-shift-all vr! swap vm! ! vp on stack
            q 21 <= [
                mv 5 divisor? [
                    q mv multiple-of-power-of-5 vrIsTrailingZeros!
                ] [
                    acceptBounds [
                        q mv mmShift - 1 - multiple-of-power-of-5 vmIsTrailingZeros!
                    ] [
                        q mv 2 + multiple-of-power-of-5 1 0 ? - ! vp!
                    ] if
                ] if
            ] when
        ] [ ! e2 < 0
            e2 neg DOUBLE_LOG10_5_NUMERATOR * DOUBLE_LOG10_5_DENOMINATOR /i 1 [-] :> q
            q e2 + e10!
            e2 neg q - :> i
            i double-pow-5-bits DOUBLE_POW5_BITCOUNT - :> k
            q k - :> j
            mmShift m2 i DOUBLE_POW5_SPLIT nth-unsafe j mul-shift-all vr! swap vm! ! vp on stack
            q 1 <= [
                mv 1 bitand bitnot q >= vrIsTrailingZeros!
                acceptBounds [
                    mv 1 - mmShift - bitnot 1 bitand q >= vmIsTrailingZeros!
                ] [ 1 - ] if ! vp!
            ] [
                q 63 < [
                    q 1 - on-bits mv bitand zero? vrIsTrailingZeros!
                ] when
            ] if
        ] if
        [ decimal-length e10 + 1 - sign ] keep ! exp sign vp
        acceptBounds vmIsTrailingZeros vrIsTrailingZeros vr vm
        prepare-output produce-output
    ] unless* ;

ALIAS: d2s print-float
