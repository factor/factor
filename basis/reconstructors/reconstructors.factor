! Copyright (C) 2010 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs fry grouping hashtables kernel make
math multiline sequences splitting.monotonic ;
IN: reconstructors


TUPLE: reconstructor row-spec combiner-spec ;



/*
ERROR: no-setter ;

: out-binder>setter ( toc -- word )
    [ class>> >persistent columns>> ]
    [ toc>> column-name>> ] bi '[ column-name>> _ = ] find
    nip [ no-setter ] unless* setter>> ;

MACRO: query-object>reconstructor ( tuple -- quot )
    out>> [ [ class>> ] bi@ = ] monotonic-split
    [ [ first class>> ] [ [ out-binder>setter ] map ] bi ] { } map>assoc
    [
        [
            first2
            [ , \ new , ]
            [ reverse [ \ swap , , (( obj obj -- obj )) , \ call-effect , ] each ] bi*
        ] each
    ] [ ] make '[ [ _ input<sequence ] ] ;
*/


/*



TUPLE: bag id beans ;
TUPLE: bean id bag-id color ;

{
    { 0 0 0 "blue" } { 0 1 0 "red" } { 0 2 0 "yellow" }
    { 1 3 1 "black" } { 1 4 1 "white" } 
    { 2 5 2 "black" } { 2 6 2 "white" }
}
{ { bag >>id } { bean >>id >>bag-id >>color } } rows>tuples

[ [ second bag-id>> ] bi@ = ] monotonic-split
[ [ first first ] [ [ second ] map ] bi >>beans ] map



T{ reconstructor
    { row-spec
        { { bag >>id } { bean >>id >>color } }
    }
    { combiner-spec
        { bag >>beans { bean bag-id>> } }
    }
}

TUPLE: foo-1 a b ;

{ { 1 "Asdf" } }
{ { foo-1 >>a >>b } }

T{ foo-1 { a 1 } { b "Asdf" } }


{
    { big-container >>id >>a }
    { medium-container >>id >>big-container-id >>b }
    { small-container >>id >>medium-container-id >>c }
} rows>tuples


{
    { third medium-container-id>> <=> }
    { second big-container-id>> <=> }
} sort-by



T{ reconstructor
    { row-spec
        {
            { big-container >>id >>a }
            { medium-container >>id >>big-container-id >>b }
            { small-container >>id >>medium-container-id >>c }
        }
    }
    { combiner-spec
        {
            T{ nested-reconstructor f
                small-container medium-container-id>>
                medium-container >>small-containers
            }

            T{ nested-reconstructor f
                medium-container big-container-id>>
                big-container >>medium-containers
            }
        }
    }
}


TUPLE: big-container id a medium-containers ;

TUPLE: medium-container id big-container-id b small-containers ;

TUPLE: small-container id medium-container-id c ;


TUPLE: nested-reconstructor
    from-class from-accessor
    to-class to-accessor ;


{
    { 0 "a" 0 0 "b" 0 0 "c" }
    { 0 "a" 0 0 "b" 1 0 "c" }
    { 0 "a" 1 0 "b" 2 1 "c" }
    { 1 "a" 2 1 "b" 3 2 "c" }
    { 1 "a" 2 1 "b" 4 2 "c" }
    { 1 "a" 2 1 "b" 5 2 "c" }
    { 1 "a" 3 1 "b" 6 3 "c" }
    { 2 "a" 4 2 "b" 7 4 "c" }
    { 2 "a" 4 2 "b" 8 4 "c" }
    { 2 "a" 5 2 "b" 9 5 "c" }
    { 2 "a" 5 2 "b" 10 5 "c" }
    { 2 "a" 5 2 "b" 11 5 "c" }
    { 2 "a" 6 2 "b" 12 6 "c" }
}

{
    { big-container >>id >>a }
    { medium-container >>id >>big-container-id >>b }
    { small-container >>id >>medium-container-id >>c }
} rows>tuples


[ [ 2 swap nth medium-container-id>> ] bi@ = ] monotonic-split
[
    [ [ third ] map ] [ first second small-containers<< ] [ ] tri
    first but-last
] map

[ [ 1 swap nth big-container-id>> ] bi@ = ] monotonic-split
[
    [ [ second ] map ] [ first first medium-containers<< ] [ ] tri
    first but-last
] map

[ first ] map

{
    T{ nested-reconstructor f
        small-container medium-container-id>>
        medium-container >>small-containers
    }

    T{ nested-reconstructor f
        medium-container big-container-id>>
        big-container >>medium-containers
    }
}





*/

ERROR: not-found key ;

: at- ( class hashtable -- n )
    ?at [ not-found ] unless ;

: nth-tuple, ( n hashtable -- )
    at- , \ swap , \ nth , ;

: splitter-quot ( combiner-spec lookup-table -- quot )
    '[
        _ [ _ nth-tuple, ] each
    ] [ ] make
    '[ [ _ bi@ = ] monotonic-split ] ;

: reconstructor>tuple-lookup-table ( reconstructor -- hashtable )
    row-spec>> [ [ first ] map ] [ length <iota> ] bi zip >hashtable ; 

: split-by-length ( seq lengths -- seq' )
    0 [ + ] accumulate swap suffix 2 <clumps>
    [ first2 rot subseq ] with map ;

: fill-new-tuple ( seq spec -- tuple )
    unclip new [
        '[ [ _ ] 2dip execute( a obj -- obj ) drop ] 2each
    ] keep ;

: row>tuples ( seq spec -- seq' )
    [ [ length 1 - ] map split-by-length ] keep
    [ fill-new-tuple ] 2map ;

: rows>tuples ( seq spec -- seq' )
    '[ _ row>tuples ] map ;
