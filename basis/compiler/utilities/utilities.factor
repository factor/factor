! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences sequences.private arrays vectors fry
math math.order namespaces assocs ;
IN: compiler.utilities

: flattener ( seq quot -- seq vector quot' )
    over length <vector> [
        dup
        '[
            @ [
                dup array?
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

: alist-max ( alist -- pair )
    [ ] [ [ [ second ] bi@ > ] most ] map-reduce ;