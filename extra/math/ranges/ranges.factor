USING: kernel layouts math namespaces sequences sequences.private ;
IN: math.ranges

: >integer ( n -- i )
    dup most-negative-fixnum most-positive-fixnum between?
    [ >fixnum ] [ >bignum ] if ;

TUPLE: range from length step ;

: <range> ( from to step -- range )
    >r over - r>
    [ / 1+ 0 max >integer ] keep
    range construct-boa ;

M: range length ( seq -- n )
    range-length ;

M: range nth-unsafe ( n range -- obj )
    [ range-step * ] keep range-from + ;

INSTANCE: range immutable-sequence

: twiddle 2dup > -1 1 ? ; inline

: (a, dup roll + -rot ; inline

: ,b) dup neg rot + swap ; inline

: [a,b] twiddle <range> ;

: (a,b] twiddle (a, <range> ;

: [a,b) twiddle ,b) <range> ;

: (a,b) twiddle (a, ,b) <range> ;

: [0,b] 0 swap [a,b] ;

: [1,b] 1 swap [a,b] ;

: [0,b) 0 swap (a,b] ;
