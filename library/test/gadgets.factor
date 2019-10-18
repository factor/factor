IN: temporary
USING: gadgets kernel lists math namespaces test sequences ;

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
        10 10 30 30 <rectangle> <gadget> rect>screen
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
    dup [ 255 0 0 ] foreground set-paint-prop ;
    
[ f ] [
    [
        0 x set
        0 y set
        35 0 rect>
        [ 10 30 50 70 ] [ funny-rect ] map
        pick-up-list
    ] with-scope
] unit-test

[ -90 ] [ 10 10 -100 -200 <line> shape-x ] unit-test
[ 20 ] [ 10 10 100 200 <line> [ 20 30 rot move-shape ] keep shape-x ] unit-test
[ 30 ] [ 10 10 100 200 <line> [ 20 30 rot move-shape ] keep shape-y ] unit-test
[ 20 ] [ 110 110 -100 -200 <line> [ 20 30 rot move-shape ] keep shape-x ] unit-test
[ 30 ] [ 110 110 -100 -200 <line> [ 20 30 rot move-shape ] keep shape-y ] unit-test
[ 10 ] [ 110 110 -100 -200 <line> [ 400 400 rot resize-shape ] keep shape-x ] unit-test
[ 400 ] [ 110 110 -100 -200 <line> [ 400 400 rot resize-shape ] keep shape-w ] unit-test

[ t ] [
    [
        100 x set
        100 y set
        #{ 110 115 }# << line f 0 0 100 150 >> inside?
    ] with-scope
] unit-test

[
    300 620
] [
    0 10 0 <pile> "pile" set
    0 0 100 100 <rectangle> <gadget> "pile" get add-gadget
    0 0 200 200 <rectangle> <gadget> "pile" get add-gadget
    0 0 300 300 <rectangle> <gadget> "pile" get add-gadget
    "pile" get pref-size
] unit-test

[ ] [ "pile" get layout* ] unit-test

[
    1 15
] [
    1 15 << line [ ] 0 0 0 14 >> [ resize-shape ] keep shape-size
] unit-test

[
    1 15
] [
    1 15 << line [ ] 0 22 -1 14 >> [ resize-shape ] keep shape-size
] unit-test
