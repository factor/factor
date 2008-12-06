! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences sequences.private arrays vectors fry
math.order ;
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

: (3each) ( seq1 seq2 seq3 quot -- n quot' )
    [ [ [ length ] tri@ min min ] 3keep ] dip
    '[ [ _ nth-unsafe ] [ _ nth-unsafe ] [ _ nth-unsafe ] tri @ ] ; inline

: 3each ( seq1 seq2 seq3 quot -- seq ) (3each) each ; inline

: 3map ( seq1 seq2 seq3 quot -- seq ) (3each) map ; inline
