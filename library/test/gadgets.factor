IN: scratchpad
USING: gadgets kernel lists math namespaces test ;

[ t ] [
    [
        2000 x set
        2000 y set
        2030 2040 <point> 10 20 300 400 <rectangle> inside?
    ] with-scope
] unit-test
[ f ] [
    [
        2000 x set
        2000 y set
        2500 2040 <point> 10 20 300 400 <rectangle> inside?
    ] with-scope
] unit-test
[ t ] [
    [
        -10 x set
        -20 y set
        0 0 <point> 10 20 300 400 <rectangle> inside?
    ] with-scope
] unit-test
[ 11 11 41 41 ] [
    default-paint [
        [
            1 x set
            1 y set
            10 10 30 30 <rectangle> <gadget> shape>screen
        ] with-scope
    ] bind
] unit-test
[ t ] [
    default-paint [
        0 0 <point> -10 -10 20 20 <rectangle> <gadget> [ pick-up ] keep =
    ] bind
] unit-test

: funny-rect ( x -- rect )
    10 10 30 <rectangle> <gadget>
    dup [ 255 0 0 ] color set-paint-property ;
    
[ f ] [
    default-paint [
        35 0 <point>
        [ 10 30 50 70 ] [ funny-rect ] map
        pick-up
    ] bind
] unit-test

[ 1 3 2 ] [ #{ 1 2 }# #{ 3 4 }# x1/x2/y1 ] unit-test
[ 1 3 4 ] [ #{ 1 2 }# #{ 3 4 }# x1/x2/y2 ] unit-test
[ 1 2 4 ] [ #{ 1 2 }# #{ 3 4 }# x1/y1/y2 ] unit-test
[ 3 2 4 ] [ #{ 1 2 }# #{ 3 4 }# x2/y1/y2 ] unit-test
