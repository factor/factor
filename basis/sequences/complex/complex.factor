USING: accessors kernel math sequences sequences.private ;
IN: sequences.complex

TUPLE: complex-sequence seq ;
INSTANCE: complex-sequence sequence

: <complex-sequence> ( sequence -- complex-sequence )
    complex-sequence boa ; inline

<PRIVATE

: complex@ ( n seq -- n' seq' )
    [ 1 shift ] [ seq>> ] bi* ; inline

PRIVATE>

M: complex-sequence length
    seq>> length -1 shift ;
M: complex-sequence nth-unsafe
    complex@ [ nth-unsafe ] [ [ 1 + ] dip nth-unsafe ] 2bi rect> ;
M: complex-sequence set-nth-unsafe
    complex@
    [ [ real-part      ] [    ] [ ] tri* set-nth-unsafe ]
    [ [ imaginary-part ] [ 1 + ] [ ] tri* set-nth-unsafe ] 3bi ;
