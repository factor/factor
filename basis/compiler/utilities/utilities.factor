! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences sequences.private arrays vectors fry
math math.order namespaces assocs locals ;
IN: compiler.utilities

: flattener ( seq quot -- seq vector quot' )
    over length <vector> [
        dup
        '[
            @ [
                dup [ array? ] [ vector? ] bi or
                [ _ push-all ] [ _ push ] if
            ] when*
        ]
    ] keep ; inline

: flattening ( seq quot combinator -- seq' )
    [ flattener ] dip dip { } like ; inline

: map-flat ( seq quot -- seq' ) [ each ] flattening ; inline

: 2map-flat ( seq quot -- seq' ) [ 2each ] flattening ; inline

SYMBOL: yield-hook

yield-hook [ [ ] ] initialize

: alist-most ( alist quot -- pair )
    [ [ ] ] dip '[ [ [ second ] bi@ @ ] most ] map-reduce ; inline

: alist-min ( alist -- pair ) [ before=? ] alist-most ;

: alist-max ( alist -- pair ) [ after=? ] alist-most ;

: penultimate ( seq -- elt ) [ length 2 - ] keep nth ;

:: compress-path ( source assoc -- destination )
    [let | destination [ source assoc at ] |
        source destination = [ source ] [
            [let | destination' [ destination assoc compress-path ] |
                destination' destination = [
                    destination' source assoc set-at
                ] unless
                destination'
            ]
        ] if
    ] ;
