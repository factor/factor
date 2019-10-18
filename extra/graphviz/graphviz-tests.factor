USING: arrays formatting graphviz graphviz.ffi
graphviz.notation graphviz.render graphviz.render.private
io.directories io.files io.files.unique kernel locals math
math.combinatorics math.parser sequences sets tools.test ;
IN: graphviz.testing

! Don't want to test canvas formats, since they'll open a
! separate window (even if it's closed, that'll call exit() and
! kill the Factor process).
!
! In fact, the exit() issue is why we probably don't even want
! these formats supported in general, and why we have
! graphviz.render:preview & preview-window.  Should probably
! gank them out of supported-formats in graphviz.ffi to begin
! with.
CONSTANT: canvas { "gtk" "x11" "xlib" }

! Had some issues with the following formats.  Graphviz 2.26.3
! would die with "Error: deflation finish problem -2 cnt=0".
! Could just be my installation, though.
CONSTANT: zlib { "svgz" "vmlz" }

! These are aliases for the neato flags -n/-n1/-n2, which
! assume that all nodes have already been positioned, and thus
! have "pos" attributes.  Since this clearly isn't always the
! case for our tests, we skip them to avoid useless rendering
! errors.
CONSTANT: neato-aliases { "nop" "nop1" "nop2" }

:: smoke-test ( graph -- pass? )
    temporary-file :> -O
    supported-formats canvas diff zlib diff [| -T |
        supported-engines neato-aliases diff [| -K |
            graph -O -T -K (graphviz)
            [ exists? ] [ delete-file ] bi
        ] all?
    ] all? ;

: K_n ( n -- graph )
    <graph>
    node[ "point" =shape ];
    graph[ "t" =labelloc "circo" =layout ];
    over number>string "K " prepend =label
    swap iota 2 [ first2 add-edge ] each-combination ;

{ t } [ 5 K_n smoke-test ] unit-test
{ t } [ 6 K_n smoke-test ] unit-test
{ t } [ 7 K_n smoke-test ] unit-test

:: partite-set ( n color -- cluster )
    color <cluster>
        color =color
        node[ color =color ];
        n iota [
            number>string color prepend add-node
        ] each ;

:: K_n,m ( n m -- graph )
    <graph>
    node[ "point" =shape ];
    graph[ "t" =labelloc "dot" =layout "LR" =rankdir ];
    n "#FF0000" partite-set
    m "#0000FF" partite-set
    add-edge
    n m "K %d,%d" sprintf =label ;

{ t } [ 3 3 K_n,m smoke-test ] unit-test
{ t } [ 3 4 K_n,m smoke-test ] unit-test
{ t } [ 5 4 K_n,m smoke-test ] unit-test

: add-cycle ( graph n -- graph' )
    [ iota add-path ] [ 1 - 0 add-edge ] bi ;

: C_n ( n -- graph )
    <graph>
    graph[ "t" =labelloc "circo" =layout ];
    node[ "point" =shape ];
    over number>string "C " prepend =label
    swap add-cycle ;

{ t } [ 5 C_n smoke-test ] unit-test
{ t } [ 6 C_n smoke-test ] unit-test
{ t } [ 7 C_n smoke-test ] unit-test

: W_n ( n -- graph )
    <graph>
    graph[ "t" =labelloc "twopi" =layout ];
    node[ "point" =shape ];
    over number>string "W " prepend =label
    over add-node
    over 1 - add-cycle
    swap [ ] [ 1 - iota >array ] bi add-edge ;

{ t } [ 6 W_n smoke-test ] unit-test
{ t } [ 7 W_n smoke-test ] unit-test
{ t } [ 8 W_n smoke-test ] unit-test

: cluster-example ( -- graph )
    <digraph>
        "dot" =layout
        0 <cluster>
            "filled" =style
            "lightgrey" =color
            node[ "filled" =style "white" =color ];
            { "a0" "a1" "a2" "a3" } ~->
            "process #1" =label
        add
        1 <cluster>
            node[ "filled" =style ];
            { "b0" "b1" "b2" "b3" } ~->
            "process #2" =label
            "blue" =color
        add
        "start" "a0" ->
        "start" "b0" ->
        "a1" "b3" ->
        "b2" "a3" ->
        "a3" "a0" ->
        "a3" "end" ->
        "b3" "end" ->
        "start" add-node[ "Mdiamond" =shape ];
        "end" add-node[ "Msquare" =shape ];
    ;

{ t } [ cluster-example smoke-test ] unit-test

: colored-circle ( i -- node )
    [ <node> ] keep
    [ 16.0 / 0.5 + =width ]
    [ 16.0 / 0.5 + =height ]
    [ 16 * "#%2x0000" sprintf =fillcolor ] tri ;

: colored-circles-example ( -- graph )
    <graph>
    graph[ "3,3" =size "circo" =layout ];
    node[ "filled" =style
          "circle" =shape
          "true"   =fixedsize
          ""       =label ];
    edge[ "invis" =style ];
    0 add-node[ "invis" =style "none" =shape ];
    16 iota [
        [ 0 -- ] [ colored-circle add ] bi
    ] each ;

{ t } [ colored-circles-example smoke-test ] unit-test

: dfa-example ( -- graph )
    <digraph>
        "LR" =rankdir
        "8,5" =size
        node[ "doublecircle" =shape ];
        { "LR_0" "LR_3" "LR_4" "LR_8" } add-nodes
        node[ "circle" =shape ];
        "LR_0" "LR_2" ->[ "SS(B)" =label ];
        "LR_0" "LR_1" ->[ "SS(S)" =label ];
        "LR_1" "LR_3" ->[ "S($end)" =label ];
        "LR_2" "LR_6" ->[ "SS(b)" =label ];
        "LR_2" "LR_5" ->[ "SS(a)" =label ];
        "LR_2" "LR_4" ->[ "S(A)" =label ];
        "LR_5" "LR_7" ->[ "S(b)" =label ];
        "LR_5" "LR_5" ->[ "S(a)" =label ];
        "LR_6" "LR_6" ->[ "S(b)" =label ];
        "LR_6" "LR_5" ->[ "S(a)" =label ];
        "LR_7" "LR_8" ->[ "S(b)" =label ];
        "LR_7" "LR_5" ->[ "S(a)" =label ];
        "LR_8" "LR_6" ->[ "S(b)" =label ];
        "LR_8" "LR_5" ->[ "S(a)" =label ];
    ;

{ t } [ dfa-example smoke-test ] unit-test

: record-example ( -- graph )
    <digraph>
        graph[ "LR" =rankdir "8,8" =size ];
        node[ 8 =fontsize "record" =shape ];

        "node0" add-node[
            "<f0> 0x10ba8| <f1>" =label
        ];
        "node1" add-node[
            "<f0> 0xf7fc4380| <f1> | <f2> |-1" =label
        ];
        "node2" add-node[
            "<f0> 0xf7fc44b8| | |2" =label
        ];
        "node3" add-node[
            "<f0> 3.43322790286038071e-06|44.79998779296875|0" =label
        ];
        "node4" add-node[
            "<f0> 0xf7fc4380| <f1> | <f2> |2" =label
        ];
        "node5" add-node[
            "<f0> (nil)| | |-1" =label
        ];
        "node6" add-node[
            "<f0> 0xf7fc4380| <f1> | <f2> |1" =label
        ];
        "node7" add-node[
            "<f0> 0xf7fc4380| <f1> | <f2> |2" =label
        ];
        "node8" add-node[
            "<f0> (nil)| | |-1" =label
        ];
        "node9" add-node[
            "<f0> (nil)| | |-1" =label
        ];
        "node10" add-node[
            "<f0> (nil)| <f1> | <f2> |-1" =label
        ];
        "node11" add-node[
            "<f0> (nil)| <f1> | <f2> |-1" =label
        ];
        "node12" add-node[
            "<f0> 0xf7fc43e0| | |1" =label
        ];

        "node0" "node1"   ->[ "f0" =tailport "f0" =headport ];
        "node0" "node2"   ->[ "f1" =tailport "f0" =headport ];
        "node1" "node3"   ->[ "f0" =tailport "f0" =headport ];
        "node1" "node4"   ->[ "f1" =tailport "f0" =headport ];
        "node1" "node5"   ->[ "f2" =tailport "f0" =headport ];
        "node4" "node3"   ->[ "f0" =tailport "f0" =headport ];
        "node4" "node6"   ->[ "f1" =tailport "f0" =headport ];
        "node4" "node10"  ->[ "f2" =tailport "f0" =headport ];
        "node6" "node3"   ->[ "f0" =tailport "f0" =headport ];
        "node6" "node7"   ->[ "f1" =tailport "f0" =headport ];
        "node6" "node9"   ->[ "f2" =tailport "f0" =headport ];
        "node7" "node3"   ->[ "f0" =tailport "f0" =headport ];
        "node7" "node1"   ->[ "f1" =tailport "f0" =headport ];
        "node7" "node8"   ->[ "f2" =tailport "f0" =headport ];
        "node10" "node11" ->[ "f1" =tailport "f0" =headport ];
        "node10" "node12" ->[ "f2" =tailport "f0" =headport ];
        "node11" "node1"  ->[ "f2" =tailport "f0" =headport ];
    ;

{ t } [ record-example smoke-test ] unit-test

! TODO add the examples from graphviz's source code (the .gv
! files in graphs/directed/ and graphs/undirected/)
