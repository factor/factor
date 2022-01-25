USING: accessors kernel math combinators sequences
sequences.private ;
IN: sequences.complex-components

TUPLE: complex-components seq ;
INSTANCE: complex-components sequence

: <complex-components> ( sequence -- complex-components )
    complex-components boa ; inline

<PRIVATE

: complex-components@ ( n seq -- remainder n' seq' )
    [ [ 1 bitand ] [ -1 shift ] bi ] [ seq>> ] bi* ; inline
: complex-component ( remainder complex -- component )
    swap {
        { 0 [ real-part ] }
        { 1 [ imaginary-part ] }
    } case ;

PRIVATE>

M: complex-components length
    seq>> length 1 shift ;
M: complex-components nth-unsafe
    complex-components@ nth-unsafe complex-component ;
M: complex-components set-nth-unsafe
    immutable ;
