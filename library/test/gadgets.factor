IN: scratchpad
USING: gadgets kernel lists math namespaces test ;

[ t ] [
    [
        2000 x set
        2000 y set
        2030 2040 rect> 10 20 300 400 <rectangle> inside?
    ] with-scope
] unit-test
[ f ] [
    [
        2000 x set
        2000 y set
        2500 2040 rect> 10 20 300 400 <rectangle> inside?
    ] with-scope
] unit-test
[ t ] [
    [
        -10 x set
        -20 y set
        0 0 rect> 10 20 300 400 <rectangle> inside?
    ] with-scope
] unit-test
[ 11 11 41 41 ] [
    [
        1 x set
        1 y set
        10 10 30 30 <rectangle> <gadget> shape>screen
    ] with-scope
] unit-test
[ t ] [
    [
        0 x set
        0 y set
        0 0 rect> -10 -10 20 20 <rectangle> <gadget> [ pick-up ] keep =
    ] with-scope
] unit-test

: funny-rect ( x -- rect )
    10 10 30 <rectangle> <gadget>
    dup [ 255 0 0 ] foreground set-paint-property ;
    
[ f ] [
    [
        0 x set
        0 y set
        35 0 rect>
        [ 10 30 50 70 ] [ funny-rect ] map
        pick-up-list
    ] with-scope
] unit-test

[ 1 3 2 ] [ #{ 1 2 }# #{ 3 4 }# x1/x2/y1 ] unit-test
[ 1 3 4 ] [ #{ 1 2 }# #{ 3 4 }# x1/x2/y2 ] unit-test
[ 1 2 4 ] [ #{ 1 2 }# #{ 3 4 }# x1/y1/y2 ] unit-test
[ 3 2 4 ] [ #{ 1 2 }# #{ 3 4 }# x2/y1/y2 ] unit-test

[ -90 ] [ 10 10 -100 -200 <line> shape-x ] unit-test
[ 20 ] [ 10 10 100 200 <line> [ 20 30 rot move-shape ] keep shape-x ] unit-test
[ 30 ] [ 10 10 100 200 <line> [ 20 30 rot move-shape ] keep shape-y ] unit-test
[ 20 ] [ 110 110 -100 -200 <line> [ 20 30 rot move-shape ] keep shape-x ] unit-test
[ 30 ] [ 110 110 -100 -200 <line> [ 20 30 rot move-shape ] keep shape-y ] unit-test
[ 10 ] [ 110 110 -100 -200 <line> [ 400 400 rot resize-shape ] keep shape-x ] unit-test
[ 400 ] [ 110 110 -100 -200 <line> [ 400 400 rot resize-shape ] keep shape-w ] unit-test
