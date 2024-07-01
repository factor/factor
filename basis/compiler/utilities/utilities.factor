! Copyright (C) 2008, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays assocs combinators.short-circuit hashtables kernel
math math.order namespaces sequences vectors ;
IN: compiler.utilities

: flattener ( seq quot -- seq vector quot' )
    over length <vector> [
        dup
        '[
            @ [
                dup { [ array? ] [ vector? ] } 1||
                [ _ push-all ] [ _ push ] if
            ] when*
        ]
    ] keep ; inline

: flattening ( seq quot combinator -- seq' )
    [ flattener ] dip dip { } like ; inline

: map-flat ( seq quot -- seq' ) [ each ] flattening ; inline

: 2map-flat ( seq quot -- seq' ) [ 2each ] flattening ; inline

: pad-tail-shorter ( seq1 seq2 elt -- seq1' seq2' )
    2over longer length swap [ pad-tail ] 2curry bi@ ;

SYMBOL: yield-hook

yield-hook [ [ ] ] initialize

: alist-most ( alist quot -- pair )
    [ [ ] ] dip '[ [ [ second ] bi@ @ ] most ] map-reduce ; inline

: alist-min ( alist -- pair ) [ before=? ] alist-most ;

: alist-max ( alist -- pair ) [ after=? ] alist-most ;

: penultimate ( seq -- elt ) [ length 2 - ] keep nth ;

:: compress-path ( source assoc -- destination )
    source assoc at :> destination
    source destination = [ source ] [
        destination assoc compress-path :> destination'
        destination' destination = [
            destination' source assoc set-at
        ] unless
        destination'
    ] if ;

: unique ( seq -- assoc )
    [ dup ] H{ } map>assoc ;

: conjoin ( elt assoc -- )
    dupd set-at ;

: conjoin-at ( value key assoc -- )
    [ dupd ?set-at ] change-at ;
