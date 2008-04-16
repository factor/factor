! Copyright (c) 2008 Eric Mertens
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math sequences locals ;
IN: project-euler.150

<PRIVATE

! sequence helper functions

: partial-sums ( seq -- seq )
    0 [ + ] accumulate swap suffix ; inline

: generate ( n quot -- seq )
    [ drop ] swap compose map ; inline

: map-infimum ( seq quot -- min )
    [ min ] compose 0 swap reduce ; inline


! triangle generator functions

: next ( t -- new-t s )
    615949 * 797807 + 1 20 shift mod dup 1 19 shift - ; inline

: sums-triangle ( -- seq )
    0 1000 [ 1+ [ next ] generate partial-sums ] map nip ;

PRIVATE>

:: (euler150) ( m -- n )
    [let | table [ sums-triangle ] |
        m [| x |
            x 1+ [| y |
                m x - [| z |
                    x z + table nth
                    [ y z + 1+ swap nth ]
                    [ y        swap nth ] bi -
                ] map partial-sums infimum
            ] map-infimum
        ] map-infimum
    ] ;

: euler150 ( -- n )
    1000 (euler150) ;
