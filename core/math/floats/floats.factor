! Copyright (C) 2004, 2010 Slava Pestov, Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel math math.order math.private ;
IN: math.floats

<PRIVATE
: float-unordered? ( x y -- ? ) [ fp-nan? ] either? ;
: float-min ( x y -- z ) [ float< ] most ; foldable
: float-max ( x y -- z ) [ float> ] most ; foldable

M: float >fixnum float>fixnum ; inline
M: float >bignum float>bignum ; inline
M: float >float ; inline

M: float hashcode* nip float>bits ; inline
M: float equal? over float? [ float= ] [ 2drop f ] if ; inline
M: float number= float= ; inline

M: float <  float< ; inline
M: float <= float<= ; inline
M: float >  float> ; inline
M: float >= float>= ; inline

M: float unordered? float-unordered? ; inline
M: float u<  float-u< ; inline
M: float u<= float-u<= ; inline
M: float u>  float-u> ; inline
M: float u>= float-u>= ; inline

M: float min over float? [ float-min ] [ call-next-method ] if ; inline
M: float max over float? [ float-max ] [ call-next-method ] if ; inline

M: float + float+ ; inline
M: float - float- ; inline
M: float * float* ; inline
M: float / float/f ; inline
M: float /f float/f ; inline
M: float /i float/f >integer ; inline

M: real abs dup 0 < [ neg ] when ; inline

M: real /mod 2dup mod [ swap [ - ] [ /i ] bi* ] keep ; inline

M: float fp-special?
    double>bits -52 shift 0x7ff [ bitand ] keep = ; inline

M: float fp-nan-payload
    double>bits 52 2^ 1 - bitand ; inline

M: float fp-nan?
    dup float= not ;

M: float fp-qnan?
    dup fp-nan? [ fp-nan-payload 51 bit? ] [ drop f ] if ; inline

M: float fp-snan?
    dup fp-nan? [ fp-nan-payload 51 bit? not ] [ drop f ] if ; inline

M: float fp-infinity?
    dup fp-special? [ fp-nan-payload zero? ] [ drop f ] if ; inline

M: float next-float
    double>bits
    dup -0.0 double>bits > [ 1 - bits>double ] [ ! negative non-zero
        dup -0.0 double>bits = [ drop 0.0 ] [ ! negative zero
            1 + bits>double ! positive
        ] if
    ] if ; inline

M: float prev-float
    double>bits
    dup -0.0 double>bits >= [ 1 + bits>double ] [ ! negative
        dup 0.0 double>bits = [ drop -0.0 ] [ ! positive zero
            1 - bits>double ! positive non-zero
        ] if
    ] if ; inline

M: float fp-sign double>bits 63 bit? ; inline

M: float neg? fp-sign ; inline

M: float abs double>bits 63 2^ bitnot bitand bits>double ; inline

PRIVATE>
