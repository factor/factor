! Copyright (C) 2017 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors arrays assocs calendar circular colors
combinators combinators.short-circuit combinators.smart
destructors formatting images.loader kernel math math.order
math.parser namespaces opengl opengl.textures random sequences
timers ui ui.commands ui.gadgets ui.gadgets.toolbar
ui.gadgets.tracks ui.gadgets.worlds ui.gestures ui.pens.solid
ui.render ui.tools.browser words ;

IN: minesweeper

CONSTANT: neighbors {
    { -1 -1 } { -1  0 } { -1  1 }
    {  0 -1 }           {  0  1 }
    {  1 -1 } {  1  0 } {  1  1 }
}

SYMBOLS: +flagged+ +question+ +clicked+ ;

TUPLE: cell #adjacent mined? state ;

: make-cells ( rows cols -- cells )
    '[ _ [ cell new ] replicate ] replicate ;

:: cell-at ( cells row col -- cell/f )
    row cells ?nth [ col swap ?nth ] [ f ] if* ;

: cells-dim ( cells -- rows cols )
    [ length ] [ first length ] bi ;

: #mines ( cells -- n )
    [ [ mined?>> ] count ] map-sum ;

: #flagged ( cells -- n )
    [ [ state>> +flagged+ = ] count ] map-sum ;

: #mines-remaining ( cells -- n )
    [ #mines ] [ #flagged ] bi - ;

: unmined-cell ( cells -- cell )
    '[ _ random random dup mined?>> ] smart-loop ;

: place-mines ( cells n -- cells )
    [ dup unmined-cell t >>mined? drop ] times ;

:: count-neighbors ( cells row col quot: ( cell -- ? ) -- n )
    cells neighbors [
        first2 [ row + ] [ col + ] bi* cell-at quot [ f ] if*
    ] with count ; inline

: adjacent-mines ( cells row col -- #mines )
    [ mined?>> ] count-neighbors ;

: adjacent-flags ( cells row col -- #flags )
    [ state>> +flagged+ = ] count-neighbors ;

:: each-cell ( ... cells quot: ( ... row col cell -- ... ) -- ... )
    cells [| row |
        [| cell col | row col cell quot call ] each-index
    ] each-index ; inline

:: update-counts ( cells -- cells )
    cells [| row col cell |
        cells row col adjacent-mines cell #adjacent<<
    ] each-cell cells ;

: reset-cells ( cells -- cells )
    [ cells-dim make-cells ] [ #mines place-mines ] bi update-counts ;

: won? ( cells -- ? )
    [ [ { [ state>> +clicked+ = ] [ mined?>> ] } 1|| ] all? ] all? ;

: lost? ( cells -- ? )
    [ [ { [ state>> +clicked+ = ] [ mined?>> ] } 1&& ] any? ] any? ;

: game-over? ( cells -- ? )
    { [ lost? ] [ won? ] } 1|| ;

: new-game? ( cells -- ? )
    [ [ state>> +clicked+ = ] any? ] none? ;

DEFER: click-cell-at

:: click-cells-around ( cells row col -- )
    neighbors [
        first2 [ row + ] [ col + ] bi* :> ( row' col' )
        cells row' col' cell-at [
            cells row' col' click-cell-at drop
        ] when
    ] each ;

:: click-cell-at ( cells row col -- ? )
    cells row col cell-at [
        cells new-game? [
            ! first click shouldn't be a mine
            dup mined?>> [
                cells unmined-cell t >>mined? drop f >>mined?
                cells update-counts drop
            ] when
        ] when
        dup state>> { +clicked+ +flagged+ } member? [ drop f ] [
            +clicked+ >>state
            { [ mined?>> not ] [ #adjacent>> 0 = ] } 1&& [
                cells row col click-cells-around
            ] when t
        ] if
    ] [ f ] if* ;

:: mark-cell-at ( cells row col -- ? )
    cells row col cell-at [
        dup state>> {
            { +clicked+ [ +clicked+ ] }
            { +flagged+ [ +question+ ] }
            { +question+ [ f ] }
            { f [ +flagged+ ] }
        } case >>state drop t
    ] [ f ] if* ;

:: open-cell-at ( cells row col -- ? )
    cells row col cell-at [
        state>> +clicked+ = [
            cells row col [ adjacent-flags ] [ adjacent-mines ] 3bi = [
                cells row col click-cells-around
            ] when
        ] when t
    ] [ f ] if* ;

TUPLE: grid-gadget < gadget cells timer textures start end hint? ;

:: <grid-gadget> ( rows cols mines -- gadget )
    grid-gadget new
        rows cols make-cells
        mines place-mines update-counts >>cells
        H{ } clone >>textures
        dup '[ _ relayout-1 ] f 1 seconds <timer> >>timer
        COLOR: gray <solid> >>interior
        "12345" <circular> >>hint? ;

M: grid-gadget graft*
    [ timer>> start-timer ] [ call-next-method ] bi ;

M: grid-gadget ungraft*
    [
        dup find-gl-context
        [ values dispose-each H{ } clone ] change-textures
        timer>> stop-timer
    ] [ call-next-method ] bi ;

M: grid-gadget pref-dim*
    cells>> cells-dim [ 32 * ] bi@ swap 58 + 2array ;

:: cell-image-path ( cell won? lost? -- image-path )
    won? lost? or cell mined?>> and [
        cell state>> {
            { +flagged+ [ "flagged.gif" ] }
            { +clicked+ [ "mineclicked.gif" ] }
            [ drop won? "flagged.gif" "mine.gif" ? ]
        } case
    ] [
        cell state>> {
            { +question+ [ "question.gif" ] }
            { +flagged+ [ lost? "misflagged.gif" "flagged.gif" ? ] }
            { +clicked+ [
                cell #adjacent>> 0 or number>string
                "open" ".gif" surround ] }
            { f [ "blank.gif" ] }
        } case
    ] if "vocab:minesweeper/_resources/" prepend ;

: digit-image-path ( ch -- image-path )
    "vocab:minesweeper/_resources/digit%c.gif" sprintf ;

:: smiley-image-path ( won? lost? clicking? -- image-path )
    {
        { [ lost? ] [ "vocab:minesweeper/_resources/smileylost.gif" ] }
        { [ won? ] [ "vocab:minesweeper/_resources/smileywon.gif" ] }
        { [ clicking? ] [ "vocab:minesweeper/_resources/smileyuhoh.gif" ] }
        [ "vocab:minesweeper/_resources/smiley.gif" ]
    } cond ;

: draw-cached-texture ( path gadget -- )
    textures>> [ load-image { 0 0 } <texture> ] cache
    [ dim>> [ 2 /i ] map ] [ draw-scaled-texture ] bi ;

:: draw-hint ( gadget -- )
    gadget hint?>> "xyzzy" sequence= [
        gadget hand-rel first2 :> ( w h )
        h 58 >= [
            h 58 - w [ 32 /i ] bi@ :> ( row col )
            gadget cells>> row col cell-at [
                mined?>> COLOR: black COLOR: white ? gl-color
                { 0 0 } { 1 1 } gl-fill-rect
            ] when*
        ] when
    ] when ;

:: draw-mines ( n gadget -- )
    gadget cells>> won? 0 n ? "%03d" sprintf [
        26 * 3 + 6 2array swap '[
            _ digit-image-path gadget draw-cached-texture
        ] with-translation
    ] each-index ;

:: draw-smiley ( gadget -- )
    gadget pref-dim first :> width
    width 2/ 26 - 3 2array [
        gadget cells>> [ won? ] [ lost? ] bi
        hand-buttons get-global empty? not
        gadget hand-click-rel [ second 58 >= ] [ f ] if* and
        smiley-image-path gadget draw-cached-texture
    ] with-translation ;

:: draw-timer ( n gadget -- )
    gadget pref-dim first :> width
    n 999 min "%03d" sprintf [
        3 swap - 26 * width swap - 3 - 6 2array swap '[
            _ digit-image-path gadget draw-cached-texture
        ] with-translation
    ] each-index ;

:: draw-cells ( gadget -- )
    gadget cells>> [ won? ] [ lost? ] bi :> ( won? lost? )
    gadget cells>> [| row col cell |
        col row [ 32 * ] bi@ 58 + 2array [
            cell won? lost? cell-image-path
            gadget draw-cached-texture
        ] with-translation
    ] each-cell ;

:: elapsed-time ( gadget -- n )
    gadget start>> [
        gadget end>> now or swap time- duration>seconds
    ] [ 0 ] if* ;

M: grid-gadget handle-gesture
    over {
        [ key-down? ] [ sym>> length 1 = ] [ sym>> " " = not ]
    } 1&& [
        2dup [ sym>> first ] [ hint?>> ] bi* circular-push
    ] when call-next-method ;

M: grid-gadget draw-gadget*
    {
        [ draw-hint ]
        [ cells>> #mines-remaining ]
        [ draw-mines ]
        [ draw-smiley ]
        [ elapsed-time ]
        [ draw-timer ]
        [ draw-cells ]
    } cleave ;

:: on-grid ( gadget quot: ( cells row col -- ? ) -- )
    gadget hand-rel first2 :> ( w h )
    h 58 >= [
        h 58 - w [ 32 /i ] bi@ :> ( row col )
        gadget cells>> :> cells
        cells game-over? [
            cells row col quot call [
                gadget start>> [ now gadget start<< ] unless
                cells game-over? [ now gadget end<< ] when
            ] when
        ] unless
    ] when gadget relayout-1 ; inline

:: on-click ( gadget -- )
    gadget hand-rel first2 :> ( w h )
    h 58 < [
        h 3 55 between?
        gadget pref-dim first 2/ w - abs 26 < and [
            gadget [ reset-cells ] change-cells
            f >>start f >>end drop
        ] when
    ] when gadget [ click-cell-at ] on-grid ;

: on-mark ( gadget -- ) [ mark-cell-at ] on-grid ;

: on-open ( gadget -- ) [ open-cell-at ] on-grid ;

: new-game ( gadget rows cols mines -- )
    [ make-cells ] dip place-mines update-counts >>cells
    f >>start f >>end relayout-window ;

: com-easy ( gadget -- ) 8 8 10 new-game ;

: com-medium ( gadget -- ) 16 16 40 new-game ;

: com-hard ( gadget -- ) 16 30 99 new-game ;

: com-help ( gadget -- ) drop "minesweeper" com-browse ;

grid-gadget "toolbar" f {
    { T{ key-down { sym "1" } } com-easy }
    { T{ key-down { sym "2" } } com-medium }
    { T{ key-down { sym "3" } } com-hard }
    { T{ key-down { sym "?" } } com-help }
} define-command-map

grid-gadget "gestures" [
    {
        { T{ button-down { # 1 } } [ relayout-1 ] }
        { T{ button-up { # 1 } } [ on-click ] }
        { T{ button-up { # 3 } } [ on-mark ] }
        { T{ button-up { # 2 } } [ on-open ] }
        { T{ key-down { sym " " } } [ on-mark ] }
        { motion [ relayout-1 ] }
    } assoc-union
] change-word-prop

TUPLE: minesweeper-gadget < track ;

: <minesweeper-gadget> ( -- gadget )
    vertical minesweeper-gadget new-track
    8 8 10 <grid-gadget>
    [ <toolbar> format-toolbar f track-add ]
    [ 1 track-add ] bi ;

M: minesweeper-gadget focusable-child* children>> second ;

MAIN-WINDOW: run-minesweeper {
        { title "Minesweeper" }
        { window-controls
            { normal-title-bar close-button minimize-button } }
    } <minesweeper-gadget> >>gadgets ;
