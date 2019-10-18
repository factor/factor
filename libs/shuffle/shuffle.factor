USING: kernel sequences ;
IN: shuffle

! Don't use these words unless you really have to (eg, calling
! crappy Win32 APIs taking 11 arguments)

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

: map-with2 ( obj obj list quot -- newseq )
    2 map-withn ; inline

: each-with2 ( obj obj list quot -- )
    2 each-withn ; inline

: dip ( x y quot -- y )
    1 ndip ; inline

: dipd ( x y quot -- y )
    2 ndip ; inline

: tuckd ( x y z -- z x y z )
    2 ntuck ; inline

: 3apply ( obj obj obj quot -- )
    3 napply ; inline

