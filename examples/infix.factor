USE: kernel
USE: lists
USE: math
USE: namespaces
USE: test
USE: vectors
USE: words

: vector-peek ( vector -- obj )
    #! Get value at end of vector without removing it.
    dup vector-length 1 - swap vector-nth ;

SYMBOL: exprs
DEFER: infix
: >e exprs get vector-push ;
: e> exprs get vector-pop ;
: e@ exprs get dup vector-length 0 = [ drop f ] [ vector-peek ] ifte ;
: e, ( obj -- ) dup cons? [ [ e, ] each ] [ , ] ifte ;
: end ( -- ) exprs get [ e, ] vector-each ;
: >postfix ( op -- ) e@ word? [ e> e> -rot 3list ] when >e ;
: token ( obj -- ) dup cons? [ infix ] when >postfix ;
: (infix) ( list -- ) [ unswons token (infix) ] when* ;

: infix ( list -- quot )
    #! Convert an infix expression (passed in as a list) to
    #! postfix.
    [ 10 <vector> exprs set (infix) end ] make-list ;

[ [ ] ] [ [ ] infix ] unit-test
[ [ 1 ] ] [ [ 1 ] infix ] unit-test
[ [ 2 3 + ] ] [ [ 2 + 3 ] infix ] unit-test
[ [ 2 3 * 4 + ] ] [ [ 2 * 3 + 4 ] infix ] unit-test
[ [ 2 3 * 4 + 5 + ] ] [ [ 2 * 3 + 4 + 5 ] infix ] unit-test
[ [ 2 3 * 4 + ] ] [ [ [ 2 * 3 ] + 4 ] infix ] unit-test
[ [ 2 3 4 + * ] ] [ [ 2 * [ 3 + 4 ] ] infix ] unit-test
[ [ 2 3 2 / 4 + * ] ] [ [ 2 * [ [ 3 / 2 ] + 4 ] ] infix ] unit-test
