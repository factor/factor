USING: sequences kernel math locals math.order math.ranges
accessors arrays namespaces make combinators
combinators.short-circuit ;
IN: lcs

<PRIVATE
: levenshtein-step ( insert delete change same? -- next )
    0 1 ? + [ [ 1+ ] bi@ ] dip min min ;

: lcs-step ( insert delete change same? -- next )
    1 -1/0. ? + max max ; ! -1/0. is -inf (float)

:: loop-step ( i j matrix old new step -- )
    i j 1+ matrix nth nth ! insertion
    i 1+ j matrix nth nth ! deletion
    i j matrix nth nth ! replace/retain
    i old nth j new nth = ! same?
    step call
    i 1+ j 1+ matrix nth set-nth ; inline

: lcs-initialize ( |str1| |str2| -- matrix )
    [ drop 0 <array> ] with map ;

: levenshtein-initialize ( |str1| |str2| -- matrix )
    [ [ + ] curry map ] with map ;

:: run-lcs ( old new init step -- matrix )
    [let | matrix [ old length 1+ new length 1+ init call ] |
        old length [| i |
            new length
            [| j | i j matrix old new step loop-step ] each
        ] each matrix ] ; inline
PRIVATE>

: levenshtein ( old new -- n )
    [ levenshtein-initialize ] [ levenshtein-step ]
    run-lcs peek peek ;

TUPLE: retain item ;
TUPLE: delete item ;
TUPLE: insert item ;

<PRIVATE
TUPLE: trace-state old new table i j ;

: old-nth ( state -- elt )
    [ i>> 1- ] [ old>> ] bi nth ;

: new-nth ( state -- elt )
    [ j>> 1- ] [ new>> ] bi nth ;

: top-beats-side? ( state -- ? )
    [ [ i>> ] [ j>> 1- ] [ table>> ] tri nth nth ]
    [ [ i>> 1- ] [ j>> ] [ table>> ] tri nth nth ] bi > ;

: retained? ( state -- ? )
    {
        [ i>> 0 > ] [ j>> 0 > ]
        [ [ old-nth ] [ new-nth ] bi = ]
    } 1&& ;

: do-retain ( state -- state )
    dup old-nth retain boa ,
    [ 1- ] change-i [ 1- ] change-j ;

: inserted? ( state -- ? )
    {
        [ j>> 0 > ]
        [ { [ i>> zero? ] [ top-beats-side? ] } 1|| ]
    } 1&& ;

: do-insert ( state -- state )
    dup new-nth insert boa , [ 1- ] change-j ;

: deleted? ( state -- ? )
    {
        [ i>> 0 > ]
        [ { [ j>> zero? ] [ top-beats-side? not ] } 1|| ]
    } 1&& ;

: do-delete ( state -- state )
    dup old-nth delete boa , [ 1- ] change-i ;

: (trace-diff) ( state -- )
    {
        { [ dup retained? ] [ do-retain (trace-diff) ] }
        { [ dup inserted? ] [ do-insert (trace-diff) ] }
        { [ dup deleted? ] [ do-delete (trace-diff) ] }
        [ drop ] ! i=j=0
    } cond ;

: trace-diff ( old new table -- diff )
    [ ] [ first length 1- ] [ length 1- ] tri trace-state boa
    [ (trace-diff) ] { } make reverse ;
PRIVATE>

: diff ( old new -- diff )
    2dup [ lcs-initialize ] [ lcs-step ] run-lcs trace-diff ;

: lcs ( seq1 seq2 -- lcs )
    [ diff [ retain? ] filter ] keep [ item>> ] swap map-as ;
