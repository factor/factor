USING: assocs heaps kernel sequences ;
IN: assoc-heaps

TUPLE: assoc-heap assoc heap ;

INSTANCE: assoc-heap assoc
INSTANCE: assoc-heap priority-queue

C: <assoc-heap> assoc-heap

: <assoc-min-heap> ( assoc -- obj ) <min-heap> <assoc-heap> ;
: <assoc-max-heap> ( assoc -- obj ) <max-heap> <assoc-heap> ;

M: assoc-heap at* ( key assoc-heap -- value ? )
    assoc-heap-assoc at* ;

M: assoc-heap assoc-size ( assoc-heap -- n )
    assoc-heap-assoc assoc-size ;

TUPLE: assoc-heap-key-exists ;

: check-key-exists ( key assoc-heap -- )
    assoc-heap-assoc key?
    [ \ assoc-heap-key-exists construct-empty throw ] when ;

M: assoc-heap set-at ( value key assoc-heap -- )
    [ check-key-exists ] 2keep
    [ assoc-heap-assoc set-at ] 3keep
    assoc-heap-heap swapd heap-push ;

M: assoc-heap heap-empty? ( assoc-heap -- ? )
    assoc-heap-assoc assoc-empty? ;

M: assoc-heap heap-length ( assoc-heap -- n )
    assoc-heap-assoc assoc-size ; 

M: assoc-heap heap-peek ( assoc-heap -- value key )
    assoc-heap-heap heap-peek ;

M: assoc-heap heap-push ( value key assoc-heap -- )
    set-at ;

M: assoc-heap heap-pop ( assoc-heap -- value key )
    dup assoc-heap-heap heap-pop swap
    rot dupd assoc-heap-assoc delete-at ;
