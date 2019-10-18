! Copyright (C) 2007 Chris Double, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences namespaces math inference.transforms
combinators macros quotations math.ranges locals ;
IN: shuffle

MACRO: ndip ( quot n -- )
    dup saver -rot restorer 3append ;

MACRO: npick ( n -- )
    1- dup saver [ dup ] rot [ r> swap ] n*quot 3append ;

MACRO: ndup ( n -- )
    dup [ npick ] curry n*quot ;

MACRO: nrot ( n -- )
    1- dup saver swap [ r> swap ] n*quot append ;

MACRO: -nrot ( n -- )
    1- dup [ swap >r ] n*quot swap restorer append ;

MACRO: nslip ( n -- )
    dup saver [ call ] rot restorer 3append ;

: dip ( x y quot -- y )
    swap slip ; inline

MACRO:: nkeep | n |
    [let | n+1 [ n 1+ ] |
        [ [ n ndup ] dip n+1 -nrot n nslip ] ] ;

MACRO: ndrop ( n -- )
    [ drop ] n*quot ;

: nnip ( n -- )
    swap >r ndrop r> ; inline

MACRO: ncurry ( n -- )
    [ curry ] n*quot ;

MACRO:: ncurry* | quot n |
    [let | n+1 [ n 1 + ] |
        [ n+1 -nrot [ n+1 nrot quot call ] n ncurry ] ] ;

MACRO:: ntuck | n |
    [let | n+2 [ n 2 + ] |
        [ dup n+2 -nrot ] ] ;

MACRO: napply ( n -- )
    2 [a,b] [| n |
        [let | n-1 [ n 1- ] |
            [ n-1 ntuck n nslip ] ]
    ] map concat >quotation [ call ] append ;

: 2swap ( x y z t -- z t x y )
    rot >r rot r> ; inline

: 2over ( a b c -- a b c a b )
    pick pick ; inline

: nipd ( a b c -- b c )
    rot drop ; inline

: 3nip ( a b c d -- d )
    3 nnip ; inline

: 4dup ( a b c d -- a b c d a b c d )
    4 ndup ; inline

: 4slip ( quot a b c d -- a b c d )
    4 nslip ; inline

: 4keep ( w x y z quot -- w x y z )
    4 nkeep ; inline 

: each-withn ( seq quot n -- )
    ncurry* each ; inline

: map-withn ( seq quot n -- newseq )
    ncurry* map ; inline

: each-with2 ( obj obj list quot -- )
    2 each-withn ; inline

: map-with2 ( obj obj list quot -- newseq )
    2 map-withn ; inline

: dipd ( x y quot -- y )
    2 ndip ; inline

: tuckd ( x y z -- z x y z )
    2 ntuck ; inline

: 3apply ( obj obj obj quot -- )
    3 napply ; inline
