! Copyright (C) 2010 Slava Pestov.
USING: accessors arrays assocs classes combinators continuations
gml.printer gml.runtime gml.types grouping hashtables kernel
math ranges sequences sorting ;
IN: gml.core

! Tokens
GML: cvx ( array -- proc ) { } <proc> ;
GML: cvlit ( proc -- array ) array>> ;
GML: exec ( obj -- ) exec-proc ;

! Stack shuffling
: pop-slice ( seq n -- subseq )
    [ tail ] [ swap shorten ] 2bi ;
: pop-slice* ( seq n -- subseq )
    over length swap - pop-slice ;

GML: pop ( a -- ) drop ;
GML: pops ( n -- )
    over operand-stack>> [ length swap - ] keep shorten ;
GML: dup ( a -- a a ) dup ;
GML: exch ( a b -- b a ) swap ;
GML: index ( n -- value )
    over operand-stack>> [ length 1 - swap - ] keep nth ;

ERROR: roll-out-of-bounds n j ;

GML: roll ( n j -- )
    2dup abs < [ roll-out-of-bounds ] when
    [ [ dup operand-stack>> ] dip over length swap - pop-slice ] dip
    neg over length rem cut-slice swap append over
    operand-stack>> push-all ;

GML: clear ( -- ) dup operand-stack>> delete-all ;
GML: cleartomark ( -- )
    dup [ find-marker ] [ operand-stack>> ] bi shorten ;
GML: count ( -- n ) dup operand-stack>> length ;
GML: counttomark ( -- n ) dup [ operand-stack>> length ] [ find-marker ] bi - ;

! Arrays
GML: ] ( -- array )
    dup
    [ [ operand-stack>> ] [ find-marker ] bi pop-slice { } like ]
    [ operand-stack>> pop* ]
    bi ;

GML: array ( n -- array )
    [ dup operand-stack>> ] dip pop-slice* { } like ;

GML: length ( array -- len ) length ;
GML: append ( array elt -- array' ) suffix ;
GML: eappend ( elt array -- array' ) swap suffix ;

GML: pop-back ( -- array' )
    ! Stupid variable arity word!
    dup pop-operand dup integer?
    [ [ dup pop-operand ] dip head* ] [ but-last ] if ;

GML: pop-front ( -- array' )
    ! Stupid variable arity word!
    dup pop-operand dup integer?
    [ [ dup pop-operand ] dip tail ] [ rest ] if ;

GML: arrayappend ( array1 array2 -- array3 ) append ;
GML: arrayremove ( array1 n -- array3 ) swap wrap remove-nth ;
GML: aload ( array -- ) over operand-stack>> push-all ;
GML: array-get ( array indices -- result ) [ (gml-get) ] with map ;
GML: flatten ( array -- flatarray )
    [ dup array? [ 1array ] unless ] map concat ;
GML: reverse ( array -- reversed ) reverse ;
GML: slice ( array n k -- slice )
    [a..b) swap '[ _ wrap nth ] map ;
GML:: subarray ( array n k -- slice )
    k n k + array subseq ;
GML: sort-number-permutation ( array -- permutation )
    zip-index sort-keys <reversed> values ;

! Dictionaries
: check-dict ( obj -- obj' ) hashtable check-instance ; inline

GML: begin ( dict -- ) check-dict over dictionary-stack>> push ;
GML: end ( -- ) dup dictionary-stack>> pop* ;
GML: dict ( -- dict ) H{ } clone ;

GML: dictfromarray ( -- dict )
    ! Stupid variable-arity word!
    dup pop-operand {
        { [ dup hashtable? ] [ [ dup pop-operand ] dip ] }
        { [ dup array? ] [ H{ } clone ] }
    } cond
    swap 2 group assoc-union! ;

GML: keys ( dict -- keys ) keys ;
GML: known ( dict key -- ? ) swap key? >true ;
GML: values ( dict -- values ) values ;
GML: where ( key -- ? )
    ! Stupid variable-arity word!
    over dictionary-stack>> [ key? ] with find swap
    [ over push-operand 1 ] [ drop 0 ] if ;

: current-dict ( gml -- assoc ) dictionary-stack>> last ; inline

GML: currentdict ( -- dict ) dup current-dict ;
GML: load ( name -- value ) over lookup-name ;

: check-name ( obj -- obj' ) gml-name check-instance ; inline

GML: def ( name value -- ) swap check-name pick current-dict set-at ;
GML: edef ( value name -- ) check-name pick current-dict set-at ;
GML: undef ( name -- ) check-name over current-dict delete-at ;

! Dictionaries and arrays
GML: get ( collection key -- elt ) (gml-get) ;
GML: put ( collection key elt -- ) (gml-put) ;
GML: copy ( collection -- collection' ) (gml-copy) ;

! Control flow
: proc>quot ( proc -- quot: ( registers gml -- registers gml ) )
    '[ _ exec-proc ] ; inline
: proc>quot1 ( proc -- quot: ( registers gml value -- registers gml ) )
    '[ over push-operand _ exec-proc ] ; inline
: proc>quot2 ( proc -- quot: ( registers gml value1 value2 -- registers gml ) )
    '[ [ over push-operand ] bi@ _ exec-proc ] ; inline

GML: if ( flag proc -- ) [ true? ] [ proc>quot ] bi* when ;
GML: ifelse ( flag proc0 proc1 -- ) [ true? ] [ proc>quot ] [ proc>quot ] tri* if ;
GML:: ifpop ( x y flag -- x/y ) flag true? y x ? ;
GML: exit ( -- ) return ;
GML: loop ( proc -- )
    '[ _ proc>quot '[ @ t ] loop ] with-return ;
GML: repeat ( n proc -- )
    '[ _ _ proc>quot times ] with-return ;
GML: for ( a s b proc -- )
    '[ _ _ _ _ [ swap <range> ] dip proc>quot1 each ] with-return ;
GML: forx ( a s b proc -- )
    '[ _ _ _ _ [ 1 - swap <range> ] dip proc>quot1 each ] with-return ;
GML: forall ( array proc -- )
    '[ _ _ proc>quot1 each ] with-return ;
GML: twoforall ( array1 array2 proc -- )
    '[ _ _ _ proc>quot2 2each ] with-return ;
GML:: map ( array proc -- )
    :> gml
    marker gml push-operand
    gml array proc proc>quot1 each
    gml-] ;
GML:: twomap ( array1 array2 proc -- )
    :> gml
    marker gml push-operand
    gml array1 array2 proc proc>quot2 2each
    gml-] ;

! Extensions to real GML
GML: print ( obj -- ) print-gml ;
GML: test ( obj1 obj2 -- ) swap assert= ;
