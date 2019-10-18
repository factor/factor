USING: kernel math namespaces sequences sequences.private ;
IN: math.ranges

TUPLE: range from length step ;
INSTANCE: range sequence

: <range> ( from to step -- range )
    >r over - r>
    [ / 1+ 0 max >fixnum ] keep
    range construct-boa ;

M: range length ( seq -- n )
    range-length ;

M: range nth-unsafe ( n range -- obj )
    [ range-step * ] keep range-from + ;

M: range set-nth-unsafe ( obj n range -- )
    immutable ;

: twiddle 2dup > -1 1 ? ; inline

: (a, dup roll + -rot ; inline

: ,b) dup neg rot + swap ; inline

: [a,b] twiddle <range> ;

: (a,b] twiddle (a, <range> ;

: [a,b) twiddle ,b) <range> ;

: (a,b) twiddle (a, ,b) <range> ;

: [0,b] 0 [a,b] ;

: [1,b] 1 [a,b] ;

: [0,b) 0 (a,b] ;
