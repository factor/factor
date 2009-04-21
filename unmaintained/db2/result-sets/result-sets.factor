! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel sequences combinators fry ;
IN: db2.result-sets

TUPLE: result-set sql in out handle n max ;

GENERIC: #rows ( result-set -- n )
GENERIC: #columns ( result-set -- n )
GENERIC: advance-row ( result-set -- )
GENERIC: more-rows? ( result-set -- ? )
GENERIC# column 1 ( result-set column -- obj )
GENERIC# column-typed 2 ( result-set column type -- sql )

: init-result-set ( result-set -- result-set )
    dup #rows >>max
    0 >>n ;

: new-result-set ( query class -- result-set )
    new
        swap {
            [ handle>> >>handle ]
            [ sql>> >>sql ]
            [ in>> >>in ]
            [ out>> >>out ]
        } cleave ;

: sql-row ( result-set -- seq )
    dup #columns [ column ] with map ;

: sql-row-typed ( result-set -- seq )
    [ #columns ] [ out>> ] [ ] tri
    '[ [ _ ] 2dip column-typed ] 2map ;
