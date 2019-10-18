USING: kernel sequences ;
IN: shuffle

: reach ( a b c d -- a b c d a )
    >r pick r> swap ; inline

: roll ( a b c d -- b c d a )
    >r rot r> swap ; inline

: -roll ( a b c d -- d a b c )
    -rot >r >r swap r> r> ; inline

: 2over ( a b c -- a b c a b )
    pick pick ; inline

: 2pick ( a b c d -- a b c d a b )
    reach reach ; inline

: nipd ( a b c -- b c )
    rot drop ; inline

: 3nip ( a b c d -- d )
    2nip nip ; inline

: keepd ( obj obj quot -- obj )
    pick >r call r> ; inline

: with2 ( obj obj quot elt -- obj obj quot )
    >r 3dup r> -rot >r >r swap >r swap call r> r> r> ; inline

: map-with2 ( obj obj list quot -- newseq )
    swap [ with2 roll ] map 3nip ; inline

: each-with2 ( obj obj list quot -- )
    swap [ with2 roll ] map 3drop ;

