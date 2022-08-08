! (c)2008 Joe Groff, see BSD license etc.
USING: accessors assocs kernel math ranges sequences
sequences.private ;
IN: sequences.n-based

TUPLE: n-based-assoc seq base ;
C: <n-based-assoc> n-based-assoc

<PRIVATE

: n-based@ ( key assoc -- n seq )
    [ base>> - ] [ nip seq>> ] 2bi ;
: n-based-keys ( assoc -- range )
    [ base>> ] [ assoc-size ] bi 1 <range> ;

PRIVATE>

INSTANCE: n-based-assoc assoc
M: n-based-assoc at* ( key assoc -- value ? )
    n-based@ 2dup bounds-check?
    [ nth-unsafe t ] [ 2drop f f ] if ;
M: n-based-assoc assoc-size ( assoc -- size )
    seq>> length ;
M: n-based-assoc >alist ( assoc -- alist )
    [ n-based-keys ] [ seq>> ] bi zip ;
M: n-based-assoc set-at ( value key assoc -- )
    n-based@ set-nth ;
M: n-based-assoc delete-at ( key assoc -- )
    [ f ] 2dip n-based@ set-nth ;
M: n-based-assoc clear-assoc ( assoc -- )
    seq>> delete-all ;
