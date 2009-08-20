! Copyright (C) 2004, 2009 Slava Pestov, Joe Groff.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math math.private ;
IN: math.floats.private

M: fixnum >float fixnum>float ; inline
M: bignum >float bignum>float ; inline

M: float >fixnum float>fixnum ; inline
M: float >bignum float>bignum ; inline
M: float >float ; inline

M: float hashcode* nip float>bits ; inline
M: float equal? over float? [ float= ] [ 2drop f ] if ; inline
M: float number= float= ; inline

M: float < float< ; inline
M: float <= float<= ; inline
M: float > float> ; inline
M: float >= float>= ; inline

M: float + float+ ; inline
M: float - float- ; inline
M: float * float* ; inline
M: float / float/f ; inline
M: float /f float/f ; inline
M: float /i float/f >integer ; inline
M: float mod float-mod ; inline

M: real abs dup 0 < [ neg ] when ; inline

M: float fp-special?
    double>bits -52 shift HEX: 7ff [ bitand ] keep = ; inline

M: float fp-nan-payload
    double>bits 52 2^ 1 - bitand ; inline

M: float fp-nan?
    dup fp-special? [ fp-nan-payload zero? not ] [ drop f ] if ; inline

M: float fp-qnan?
    dup fp-nan? [ fp-nan-payload 51 2^ bitand zero? not ] [ drop f ] if ; inline

M: float fp-snan?
    dup fp-nan? [ fp-nan-payload 51 2^ bitand zero? ] [ drop f ] if ; inline

M: float fp-infinity?
    dup fp-special? [ fp-nan-payload zero? ] [ drop f ] if ; inline

M: float next-float ( m -- n )
    double>bits
    dup -0.0 double>bits > [ 1 - bits>double ] [ ! negative non-zero
        dup -0.0 double>bits = [ drop 0.0 ] [ ! negative zero
            1 + bits>double ! positive
        ] if
    ] if ; inline

M: float prev-float ( m -- n )
    double>bits
    dup -0.0 double>bits >= [ 1 + bits>double ] [ ! negative
        dup 0.0 double>bits = [ drop -0.0 ] [ ! positive zero
            1 - bits>double ! positive non-zero
        ] if
    ] if ; inline
