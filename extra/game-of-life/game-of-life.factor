! Copyright (C) 2018 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors arrays assocs bit-arrays calendar circular
colors.constants combinators fry kernel locals math math.order
math.ranges namespaces opengl random sequences timers ui
ui.commands ui.gadgets ui.gadgets.toolbar ui.gadgets.tracks
ui.gestures ui.render words ;

IN: game-of-life

: make-grid ( rows cols -- grid )
    '[ _ <bit-array> <circular> ] replicate <circular> ;

: grid-dim ( grid -- rows cols )
    [ length ] [ first length ] bi ;

CONSTANT: neighbors {
    { -1 -1 } { -1  0 } { -1  1 }
    {  0 -1 }           {  0  1 }
    {  1 -1 } {  1  0 } {  1  1 }
}

:: count-neighbors ( grid -- counts )
    grid grid-dim :> ( rows cols )
    rows <iota> [| j |
        cols <iota> [| i |
            neighbors [
                first2 [ i + ] [ j + ] bi* grid nth nth
            ] count
        ] map
    ] map ;

:: next-step ( grid -- )
    grid count-neighbors :> neighbors
    grid [| row j |
        row [| cell i |
            i j neighbors nth nth :> n
            cell [
                n 2 3 between? i j grid nth set-nth
            ] [
                n 3 = [
                    t i j grid nth set-nth
                ] when
            ] if
        ] each-index
    ] each-index ;

TUPLE: grid-gadget < gadget grid size timer ;

: <grid-gadget> ( grid -- gadget )
    grid-gadget new
        swap >>grid
        20 >>size
        dup '[ _ [ grid>> next-step ] [ relayout-1 ] bi ]
        f 1/5 seconds <timer> >>timer ;

M: grid-gadget graft*
    [ timer>> start-timer ] [ call-next-method ] bi ;

M: grid-gadget ungraft*
    [ timer>> stop-timer ] [ call-next-method ] bi ;

M: grid-gadget pref-dim*
    [ grid>> grid-dim ] [ size>> '[ _ * ] bi@ 2array ] bi ;

:: update-grid ( gadget -- )
    gadget dim>> first2 :> ( w h )
    gadget size>> :> size
    h w [ size /i ] bi@ :> ( new-rows new-cols )
    gadget grid>> :> grid
    grid grid-dim :> ( rows cols )
    rows new-rows = not
    cols new-cols = not or [
        new-rows new-cols make-grid :> new-grid
        rows new-rows min <iota> [| j |
            cols new-cols min <iota> [| i |
                i j grid nth nth
                i j new-grid nth set-nth
            ] each
        ] each
        new-grid gadget grid<<
    ] when ;

:: draw-cells ( gadget -- )
    COLOR: black gl-color
    gadget size>> :> size
    gadget grid>> [| row j |
        row [| cell i |
            cell [
                i j [ size * ] bi@ 2array { size size } gl-fill-rect
            ] when
        ] each-index
    ] each-index ;

:: draw-lines ( gadget -- )
    gadget size>> :> size
    gadget grid>> grid-dim :> ( rows cols )
    COLOR: gray gl-color
    cols rows [ size * ] bi@ :> ( w h )
    rows [0,b] [| j |
        j size * :> y
        { 0 y } { w y } gl-line
        cols [0,b] [| i |
            i size * :> x
            { x 0 } { x h } gl-line
        ] each
    ] each ;

M: grid-gadget draw-gadget*
    [ update-grid ] [ draw-cells ] [ draw-lines ] tri ;

:: on-click ( gadget -- )
    gadget size>> :> size
    gadget grid>> grid-dim :> ( rows cols )
    gadget hand-rel first2 [ size /i ] bi@ :> ( i j )
    i 0 cols 1 - between?
    j 0 rows 1 - between? and [
        i j gadget grid>> nth [ not ] change-nth
    ] when gadget relayout-1 ;

:: on-drag ( gadget -- )
    gadget size>> :> size
    gadget grid>> grid-dim :> ( rows cols )
    gadget hand-rel first2 [ size /i ] bi@ :> ( i j )
    i 0 cols 1 - between?
    j 0 rows 1 - between? and [
        t i j gadget grid>> nth set-nth
    ] when gadget relayout-1 ;

: on-scroll ( gadget -- )
    [
        scroll-direction get second {
            { [ dup 0 > ] [ 2 ] }
            { [ dup 0 < ] [ -2 ] }
            [ 0 ]
        } cond nip + 4 30 clamp
    ] change-size relayout-1 ;

:: com-play ( gadget -- )
    gadget timer>> thread>> [
        gadget timer>> start-timer
    ] unless ;

:: com-step ( gadget -- )
    gadget grid>> next-step
    gadget relayout-1 ;

:: com-stop ( gadget -- )
    gadget timer>> thread>> [
        gadget timer>> stop-timer
    ] when ;

:: com-clear ( gadget -- )
    gadget grid>> [ seq>> clear-bits ] each
    gadget relayout-1 ;

:: com-random ( gadget -- )
    gadget grid>> [ [ drop { t f } random ] map! drop ] each
    gadget relayout-1 ;

:: com-glider ( gadget -- )
    gadget grid>> :> grid
    { { 2 1 } { 3 2 } { 1 3 } { 2 3 } { 3 3 } }
    [ first2 grid nth t -rot set-nth ] each
    gadget relayout-1 ;

grid-gadget "toolbar" f {
    { T{ key-down { sym "1" } } com-play }
    { T{ key-down { sym "2" } } com-stop }
    { T{ key-down { sym "3" } } com-clear }
    { T{ key-down { sym "4" } } com-random }
    { T{ key-down { sym "5" } } com-glider }
    { T{ key-down { sym "6" } } com-step }
} define-command-map

grid-gadget "gestures" [
    {
        { T{ key-down f { A+ } "F" } [ toggle-fullscreen ] }
        { T{ button-down { # 1 } } [ on-click ] }
        { T{ drag { # 1 } } [ on-drag ] }
        { mouse-scroll [ on-scroll ] }
    } assoc-union
] change-word-prop

TUPLE: life-gadget < track ;

: <life-gadget> ( -- gadget )
    vertical life-gadget new-track
    20 20 make-grid <grid-gadget>
    [ <toolbar> format-toolbar f track-add ]
    [ 1 track-add ] bi ;

M: life-gadget focusable-child* children>> second ;

MAIN-WINDOW: life-window {
        { title "Game of Life" }
    } <life-gadget> >>gadgets ;
