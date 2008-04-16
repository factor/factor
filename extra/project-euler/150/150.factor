USING: kernel math math.ranges math.parser sequences io locals namespaces ;

IN: project-euler.150

: next-t ( t -- t' )
    615949 * 797807 + 1 20 shift rem ; inline

: next-s ( t -- s )
    1 19 shift - ; inline

: generate ( -- seq )
    0 500500 [ drop next-t dup next-s ] map nip ;

: start-index ( i -- n )
    dup 1- * 2/ ; inline

: partial-sums ( seq -- seq )
    0 [ + ] accumulate swap suffix ; inline

: as-triangle ( i seq -- slices )
    swap [1,b] [ [ start-index dup ] keep + rot <slice> ] with map ;

: sums-triangle ( -- seqs )
    1000 generate as-triangle [ partial-sums ] map ;

SYMBOL: best

: check-best ( i -- )
    best [ min ] change ; inline

:: (euler150) ( m -- n )
    [ [let | table [ sums-triangle ] |
        0 best set
        m [| x |
            x 1+ [| y | 
                1000 x - [| z |
                    x z + table nth
                    [ y z + 1+ swap nth ] [ y swap nth ] bi -
                ] map partial-sums infimum check-best
            ] each
        ] each
      ]
    best get ] with-scope ;

: euler150 ( -- n )
    1000 (euler150) ;
