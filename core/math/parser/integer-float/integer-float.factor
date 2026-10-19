! Encode literal IEEE binary64 payloads using integer operations only.
USING: kernel math math.order ;
IN: math.parser.integer-float

<PRIVATE

: integer-power ( base exponent -- power )
    [ 1 ] 2dip [
        dup odd? [ [ [ * ] keep ] [ 1 - ] bi* ] when
        [ sq ] [ 2/ ] bi*
    ] until-zero drop ;

: below-binary-exponent? ( numerator denominator exponent -- ? )
    dup 0 >= [ shift < ] [ neg swap [ shift ] dip < ] if ;

: ratio-binary-exponent ( numerator denominator -- exponent )
    2dup [ log2 ] bi@ -
    [ below-binary-exponent? ] 3keep 2nip swap [ 1 - ] when ;

: scale-ratio ( numerator denominator shift -- numerator' denominator' )
    dup 0 >= [ swap [ shift ] dip ] [ neg shift ] if ;

: round-ratio-even ( numerator denominator -- significand )
    [ /mod ] keep over 2 * swap - nip
    dup 0 > [ drop 1 + ] [
        zero? [ dup odd? [ 1 + ] when ] when
    ] if ;

PRIVATE>

! Positive exact ratios; sign is attached separately by the number parser.
: ratio>binary64-bits ( numerator denominator -- bits )
    over zero? [ 2drop 0 ] [
        2dup ratio-binary-exponent
        dup 1023 > [ 3drop 0x7ff0000000000000 ] [
            dup -1022 < [
                drop 1074 scale-ratio round-ratio-even
            ] [
                [ 52 swap - scale-ratio round-ratio-even ] keep
                1022 + 52 shift +
            ] if
        ] if
    ] if ;

: scaled-integer>binary64-bits ( mantissa base exponent -- bits )
    dup 0 >= [ integer-power * 1 ] [ neg integer-power ] if
    ratio>binary64-bits ;
