IN: kernel
USE: arithmetic
USE: combinators
USE: lists
USE: logic
USE: namespaces
USE: stack
USE: strings
USE: vectors
USE: words

: hashcode ( obj -- hash )
    #! If two objects are =, they must have equal hashcodes.
    [
        [ cons? ] [ 4 cons-hashcode ]
        [ string? ] [ str-hashcode ]
        [ fixnum? ] [ ( return the object ) ]
        [ drop t ] [ drop 0 ]
    ] cond ;

: = ( obj obj -- ? )
    #! Push t if a is isomorphic to b.
    2dup eq? [
        2drop t
    ] [
        [
            [ cons? ] [ cons= ]
            [ string? ] [ str= ]
            [ drop t ] [ 2drop f ]
        ] cond
    ] ifte ;

: clone ( obj -- obj )
    [
        [ cons? ] [ clone-list ]
        [ vector? ] [ clone-vector ]
        [ drop t ] [ ( return the object ) ]
    ] cond ;

: class-of ( obj -- name )
    [
        [ fixnum? ] [ drop "fixnum" ]
        [ cons?   ] [ drop "cons" ]
        [ word?   ] [ drop "word" ]
        [ f =     ] [ drop "f" ]
        [ t =     ] [ drop "t" ]
        [ vector? ] [ drop "vector" ]
        [ string? ] [ drop "string" ]
        [ sbuf?   ] [ drop "sbuf" ]
        [ handle? ] [ drop "handle" ]
        [ drop t  ] [ drop "unknown" ]
    ] cond ;

: toplevel ( -- )
    0 <vector> set-datastack
    0 <vector> set-namestack
    global >n
    0 <vector> set-callstack ;

!!! HACK

IN: strings
: >upper ;
: >lower ;
IN: lists
: sort ;
