! Copyright (C) 2008 William Schlieper
! See http://factorcode.org/license.txt for BSD license.

USING: kernel continuations combinators sequences quotations arrays namespaces
       fry summary assocs math math.order macros ;

IN: backtrack

SYMBOL: failure

ERROR: amb-failure ;

M: amb-failure summary drop "Backtracking failure" ;

: fail ( -- )
    failure get [ continue ]
    [ amb-failure ] if* ;

: require ( ? -- )
    [ fail ] unless ;

MACRO: checkpoint ( quot -- quot' )
    '[ failure get ,
       '[ '[ failure set , continue ] callcc0
          , failure set @ ] callcc0 ] ;

: number-from ( from -- from+n )
    [ 1 + number-from ] checkpoint ;

<PRIVATE

: unsafe-number-from-to ( to from -- to from+n )
    2dup = [ [ 1 + unsafe-number-from-to ] checkpoint ] unless ;

: number-from-to ( to from -- to from+n )
    2dup < [ fail ] when unsafe-number-from-to ;

: amb-integer ( seq -- int )
    length 1 - 0 number-from-to nip ;

MACRO: unsafe-amb ( seq -- quot )
    dup length 1 =
    [ first 1quotation ]
    [ [ first ] [ rest ] bi
      '[ , [ drop , unsafe-amb ] checkpoint ] ] if ;

PRIVATE> 

: amb-lazy ( seq -- elt )
    [ amb-integer ] [ nth ] bi ;

: amb ( seq -- elt )
    dup empty?
    [ drop fail f ]
    [ unsafe-amb ] if ; inline

MACRO: amb-execute ( seq -- quot )
    [ length 1 - ] [ <enum> [ 1quotation ] assoc-map ] bi
    '[ , 0 unsafe-number-from-to nip , case ] ;

: if-amb ( true false -- )
    [
        [ { t f } amb ]
        [ '[ @ require t ] ]
        [ '[ @ f ] ]
        tri* if
    ] with-scope ; inline

