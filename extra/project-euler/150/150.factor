! Copyright (c) 2008 Eric Mertens
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math math.order sequences sequences.private
locals hints ;
IN: project-euler.150

<PRIVATE

! sequence helper functions

: partial-sums ( seq -- sums )
    0 [ + ] accumulate swap suffix ; inline

: (partial-sum-infimum) ( inf sum elt -- inf sum )
    + [ min ] keep ; inline

: partial-sum-infimum ( seq -- seq )
    0 0 rot [ (partial-sum-infimum) ] each drop ; inline

: generate ( n quot -- seq )
    [ drop ] prepose map ; inline

: map-infimum ( seq quot -- min )
    [ min ] compose 0 swap reduce ; inline


! triangle generator functions

: next ( t -- new-t s )
    615949 * 797807 + 20 2^ rem dup 19 2^ - ; inline

: sums-triangle ( -- seq )
    0 1000 [ 1+ [ next ] generate partial-sums ] map nip ; 

PRIVATE>

:: (euler150) ( m -- n )
    [let | table [ sums-triangle ] |
        m [| x |
            x 1+ [| y |
                m x - [| z |
                    x z + table nth-unsafe
                    [ y z + 1+ swap nth-unsafe ]
                    [ y        swap nth-unsafe ] bi -
                ] map partial-sum-infimum
            ] map-infimum
        ] map-infimum
    ] ;

HINTS: (euler150) fixnum ;

: euler150 ( -- n )
    1000 (euler150) ;
