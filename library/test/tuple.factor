IN: temporary
USING: generic kernel test math parser ;

TUPLE: rect x y w h ;
C: rect
    [ set-rect-h ] keep
    [ set-rect-w ] keep
    [ set-rect-y ] keep
    [ set-rect-x ] keep ;
    
: move ( x rect -- )
    [ rect-x + ] keep set-rect-x ;

[ f ] [ 10 20 30 40 <rect> dup clone 5 swap [ move ] keep = ] unit-test

[ t ] [ 10 20 30 40 <rect> dup clone 0 swap [ move ] keep = ] unit-test

GENERIC: delegation-test
M: object delegation-test drop 3 ;
TUPLE: quux-tuple ;
C: quux-tuple ;
M: quux-tuple delegation-test drop 4 ;
TUPLE: quuux-tuple ;
C: quuux-tuple
    [ set-delegate ] keep ;

[ 3 ] [ <quux-tuple> <quuux-tuple> delegation-test ] unit-test

GENERIC: delegation-test-2
TUPLE: quux-tuple-2 ;
C: quux-tuple-2 ;
M: quux-tuple-2 delegation-test-2 drop 4 ;
TUPLE: quuux-tuple-2 ;
C: quuux-tuple-2
    [ set-delegate ] keep ;

[ 4 ] [ <quux-tuple-2> <quuux-tuple-2> delegation-test-2 ] unit-test

! Make sure we handle changing shapes!

[
    100
] [
    TUPLE: point x y ;
    C: point [ set-point-y ] keep [ set-point-x ] keep ;
    
    100 200 <point>
    
    ! Use eval to sequence parsing explicitly
    "TUPLE: point x y z ;" eval
    
    point-x
] unit-test
