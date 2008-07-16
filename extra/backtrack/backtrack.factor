! Copyright (C) 2008 William Schlieper
! See http://factorcode.org/license.txt for BSD license.

USING: kernel continuations combinators sequences quotations arrays namespaces
       fry summary assocs math math.order macros ;

IN: backtrack

SYMBOL: failure
V{ } failure set-global

ERROR: amb-failure ;

M: amb-failure summary drop "Backtracking failure" ;

: fail ( -- )
    failure get dup empty? [ amb-failure ]
    [ pop continue ] if ;

: require ( ? -- )
    [ fail ] unless ;

MACRO: checkpoint ( quot -- quot' )
    '[ [ '[ failure get push , continue ] callcc0 @ ] callcc0 ] ;

: number-from ( from -- from+n )
    [ 1 + number-from ] checkpoint ;

<PRIVATE

: number-from-to ( to from -- to from+n )
    2dup <=>
    { { +lt+ [ fail ] }
      { +eq+ [ ] }
      { +gt+ [ [ 1 + number-from-to ] checkpoint ] } } case ;

: amb-integer ( seq -- int )
    length 1 - 0 number-from-to nip ;

PRIVATE> 

: amb-lazy ( seq -- elt )
    [ amb-integer ] [ nth ] bi ;

MACRO: amb ( seq -- quot )
    dup length
    { { 0 [ drop [ fail f ] ] }
      { 1 [ first 1quotation ] }
      [ drop [ first ] [ rest ] bi
        '[ , [ drop , amb ] checkpoint ] ] } case ;

MACRO: amb-execute ( seq -- quot )
    [ length ] [ <enum> [ 1quotation ] assoc-map ] bi
    '[ , amb , case ] ;

: if-amb ( true false -- )
    [
        [ { t f } amb ]
        [ '[ @ require t ] ]
        [ '[ @ f ] ]
        tri* if
    ] with-scope ; inline

