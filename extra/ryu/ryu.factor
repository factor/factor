! Copyright (C) 2018 Alexander Ilin.
! See http://factorcode.org/license.txt for BSD license.
USING: formatting kernel locals math math.bitwise math.functions
math.order ryu.data sequences shuffle strings vectors ;

IN: ryu

<PRIVATE

: mul-shift ( x mul shift -- y )
    [ first2 rot [ * ] keep swapd * -64 shift + ] [ 64 - neg ] bi* shift ;

: mul-shift-all ( mmShift m mul shift -- vm vp vr )
    [ 4 * ] 2dip
    [ [ 1 - swap - ] 2dip mul-shift ]
    [ [ 2 +        ] 2dip mul-shift ]
    [                     mul-shift ] 3tri ;

:: pow-5-factor ( x -- y )
    x :> value!
    f 0 [ 2dup x <= swap not and ] [
        value 5 /mod zero? [ value! 1 + ] [ nipd swap ] if
    ] while nip ; inline

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

:: prepare-output ( vp! vplength acceptBounds vmIsTrailingZeros! vrIsTrailingZeros! vr! vm! -- vplength' output )
    ! vr is converted into the output
    0 vplength
    ! the if has this stack-effect: ( lastRemovedDigit vplength -- lastRemovedDigit' vplength' output )
    vmIsTrailingZeros vrIsTrailingZeros or [
        ! rare
        [ vp 10 /i vm 10 /i 2dup > ] [
            vm! vp!
            vmIsTrailingZeros [ vm 10 divisor? vmIsTrailingZeros! ] when
            vrIsTrailingZeros [ over zero? vrIsTrailingZeros! ] when
            vr 10 /mod -roll vr! nip ! lastRemovedDigit!
            1 - ! vplength!
        ] while 2drop
        vmIsTrailingZeros [
            [ vm dup 10 /i dup 10 * swapd = ] [
                vm!
                vrIsTrailingZeros [ over zero? vrIsTrailingZeros! ] when
                vr 10 /mod -roll vr! nip ! lastRemovedDigit!
                vp 10 /i vp!
                1 - ! vplength!
            ] while drop ! Drop (vm 10 /i) result from the while condition.
        ] when
        vrIsTrailingZeros [
            over 5 = [
                vr even? [ 4 -rot nip ] when ! 4 lastRemovedDigit!
            ] when
        ] when
        vr pick 5 >= [ 1 + ] [
            dup vm = [
                acceptBounds vmIsTrailingZeros and not [ 1 + ] when
            ] when
        ] if
    ] [
        ! common
        [ vp 10 /i vm 10 /i 2dup > ] [
            vm! vp!
            vr 10 /mod -roll vr! nip ! lastRemovedDigit!
            1 - ! vplength!
        ] while 2drop
        vr dup vm = [ 1 + ] [
            pick 5 >= [ 1 + ] when
        ] if
    ] if nipd ; inline

: write-char ( index seq char -- index+1 seq' )
    -rot [ tuck ] dip [ set-nth 1 + ] keep ; inline

: write-exp ( exp index result -- result' )
    CHAR: e write-char
    pick neg? [
        CHAR: - write-char [ neg ] 2dip
    ] when
    pick dup 100 >= [
        100 /i CHAR: 0 + write-char
        [ 100 mod 2 * ] 2dip
        pick DIGIT_TABLE nth write-char
        [ 1 + DIGIT_TABLE nth ] 2dip [ set-nth ] keep
    ] [
        10 >= [
            [ 2 * ] 2dip
            pick DIGIT_TABLE nth write-char
            [ 1 + DIGIT_TABLE nth ] 2dip [ set-nth ] keep
        ] [
            [ CHAR: 0 + ] 2dip [ set-nth ] keep
        ] if
    ] if ; inline

:: produce-output ( exp sign olength output2! -- string )
    25 <vector> 0 :> ( result i! )
    0 sign [ CHAR: - swap result set-nth 1 ] when :> index!
    [ output2 10000 >= ] [
        output2 dup 10000 /i dup output2! 10000 * - :> c
        index olength + i - 1 - :> res-index
        c 100 mod 2 *
        dup DIGIT_TABLE nth res-index result set-nth
        1 + DIGIT_TABLE nth res-index 1 + result set-nth
        c 100 /i 2 *
        dup DIGIT_TABLE nth res-index 2 - result set-nth
        1 + DIGIT_TABLE nth res-index 1 - result set-nth
        i 4 + i!
    ] while
    output2 100 >= [
        output2 dup 100 /i dup output2! 100 * - 2 * :> c
        index olength + i - :> res-index
        c DIGIT_TABLE nth res-index 1 - result set-nth
        c 1 + DIGIT_TABLE nth res-index result set-nth
        i 2 + i!
    ] when
    output2 10 >= [
        output2 2 * :> c
        index olength + i - :> res-index
        c 1 + DIGIT_TABLE nth res-index result set-nth
        c DIGIT_TABLE nth index result set-nth
    ] [ CHAR: 0 output2 + index result set-nth ] if
    index 1 + index!
    olength 1 > [
        CHAR: . index result set-nth
        index olength + index!
    ] when exp index result write-exp >string ; inline

PRIVATE>

:: print-float ( value -- string )
    value >float unpack-bits [
        [ 5drop ] dip
    ] [| e2 m2 acceptBounds ieeeExponent<=1 sign |
        m2 4 * :> mv
        mantissaBits 2^ m2 = not ieeeExponent<=1 or 1 0 ? :> mmShift
        f f 0 0 0 :> ( vmIsTrailingZeros! vrIsTrailingZeros! e10! vr! vm! )
        ! After the following loop vp is left on stack.
        e2 0 >= [
            e2 DOUBLE_LOG10_2_NUMERATOR * DOUBLE_LOG10_2_DENOMINATOR /i 0 max :> q
            q e10!
            q double-pow-5-bits DOUBLE_POW5_INV_BITCOUNT + 1 - :> k
            q k + e2 - :> i
            mmShift m2 q DOUBLE_POW5_INV_SPLIT nth i mul-shift-all vr! swap vm! ! vp on stack
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
            mmShift m2 i DOUBLE_POW5_SPLIT nth j mul-shift-all vr! swap vm! ! vp on stack
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
        dup decimal-length ! vp vplength
        dup e10 + 1 - sign 2swap ! exp and sign for produce-output
        acceptBounds vmIsTrailingZeros vrIsTrailingZeros vr vm
        prepare-output produce-output
    ] if* ;

ALIAS: d2s print-float
