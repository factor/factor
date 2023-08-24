! Copyright (C) 2018 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors arrays assocs bit-arrays byte-arrays calendar
colors combinators kernel kernel.private math
math.order ranges namespaces opengl random sequences
sequences.private timers ui ui.commands ui.gadgets
ui.gadgets.toolbar ui.gadgets.tracks ui.gestures ui.render words ;

IN: game-of-life

: make-grid ( rows cols -- grid )
    '[ _ <bit-array> ] replicate ;

: grid-dim ( grid -- rows cols )
    [ length ] [ first length ] bi ;

: random-grid! ( grid -- )
    [
        [ length>> ] [ underlying>> length random-bytes ] bi
        bit-array boa
    ] map! drop ;

:: count-neighbors ( grid -- counts )
    grid grid-dim { fixnum fixnum } declare :> ( rows cols )
    rows 1 - { fixnum } declare :> max-rows
    cols 1 - { fixnum } declare :> max-cols
    rows [ cols <byte-array> ] replicate :> neighbors
    grid { array } declare [| row j |
        j 0 eq? [ max-rows ] [ j 1 - ] if
        j
        j max-rows eq? [ 0 ] [ j 1 + ] if
        [ neighbors nth-unsafe { byte-array } declare ] tri@ :>
        ( above same below )

        row { bit-array } declare [| cell i |
            cell [
                i 0 eq? [ max-cols ] [ i 1 - ] if
                i
                i max-cols eq? [ 0 ] [ i 1 + ] if

                [ [ above [ 1 + ] change-nth-unsafe ] tri@ ]
                [ nip [ same [ 1 + ] change-nth-unsafe ] bi@ ]
                [ [ below [ 1 + ] change-nth-unsafe ] tri@ ]
                3tri
            ] when
        ] each-index
    ] each-index neighbors ;

:: next-step ( grid -- )
    grid count-neighbors { array } declare :> neighbors
    grid { array } declare [| row j |
        j neighbors nth-unsafe { byte-array } declare :> neighbor-row
        row { bit-array } declare [| cell i |
            i neighbor-row nth-unsafe
            cell [
                2 3 between? i row set-nth-unsafe
            ] [
                3 = [ t i row set-nth-unsafe ] when
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

M: grid-gadget ungraft*
    [ timer>> stop-timer ] [ call-next-method ] bi ;

M: grid-gadget pref-dim*
    [ grid>> grid-dim swap ] [ size>> '[ _ * ] bi@ 1 + 2array ] bi ;

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
    gadget grid>> { array } declare [| row j |
        row { bit-array } declare [| cell i |
            cell [
                i j [ size * ] bi@ 2array
                { size size } gl-fill-rect
            ] when
        ] each-index
    ] each-index ;

:: draw-lines ( gadget -- )
    gadget size>> :> size
    gadget grid>> grid-dim :> ( rows cols )
    COLOR: gray gl-color
    cols rows [ size * ] bi@ :> ( w h )
    rows [0..b] [| j |
        j size * :> y
        { 0 y } { w y } gl-line
        cols [0..b] [| i |
            i size * :> x
            { x 0 } { x h } gl-line
        ] each
    ] each ;

M: grid-gadget draw-gadget*
    [ update-grid ] [ draw-cells ] [ draw-lines ] tri ;

SYMBOL: last-click

:: on-click ( gadget -- )
    gadget size>> :> size
    gadget grid>> grid-dim :> ( rows cols )
    gadget hand-rel first2 [ size /i ] bi@ :> ( i j )
    i 0 cols 1 - between?
    j 0 rows 1 - between? and [
        i j gadget grid>> nth
        [ not dup last-click set ] change-nth
    ] when gadget relayout-1 ;

:: on-drag ( gadget -- )
    gadget size>> :> size
    gadget grid>> grid-dim :> ( rows cols )
    gadget hand-rel first2 [ size /i ] bi@ :> ( i j )
    i 0 cols 1 - between?
    j 0 rows 1 - between? and [
        last-click get i j gadget grid>> nth set-nth
    ] when gadget relayout-1 ;

: on-scroll ( gadget -- )
    [
        scroll-direction get second {
            { [ dup 0 > ] [ -2 ] }
            { [ dup 0 < ] [ 2 ] }
            [ 0 ]
        } cond nip + 4 30 clamp
    ] change-size relayout-1 ;

:: com-play ( gadget -- )
    gadget timer>> restart-timer ;

:: com-step ( gadget -- )
    gadget grid>> next-step
    gadget relayout-1 ;

:: com-stop ( gadget -- )
    gadget timer>> stop-timer ;

:: com-clear ( gadget -- )
    gadget grid>> [ clear-bits ] each
    gadget relayout-1 ;

:: com-random ( gadget -- )
    gadget grid>> random-grid! gadget relayout-1 ;

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
