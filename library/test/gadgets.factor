IN: scratchpad
USING: gadgets kernel lists math namespaces test ;

[ t ] [
    [
        2000 x set
        2000 y set
        2030 2040 rect> 10 20 300 400 <rect> inside?
    ] with-scope
] unit-test
[ f ] [
    [
        2000 x set
        2000 y set
        2500 2040 rect> 10 20 300 400 <rect> inside?
    ] with-scope
] unit-test
[ t ] [
    [
        -10 x set
        -20 y set
        0 0 rect> 10 20 300 400 <rect> inside?
    ] with-scope
] unit-test
[ 11 11 41 41 ] [
    default-paint [
        [
            1 x set
            1 y set
            10 10 30 30 <rect> <gadget> shape>screen
        ] with-scope
    ] bind
] unit-test
[ t ] [
    default-paint [
        0 0 rect> -10 -10 20 20 <rect> <gadget> [ pick-up ] keep =
    ] bind
] unit-test

: funny-rect ( x -- rect )
    10 10 30 <rect> <gadget>
    dup [ 255 0 0 ] color set-paint-property
    dup t filled set-paint-property ;
    
[ f ] [
    default-paint [
        35 0 rect>
        [ 10 30 50 70 ] [ funny-rect ] map
        pick-up
    ] bind
] unit-test
