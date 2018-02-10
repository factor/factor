! Copyright (C) 2017 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors arrays assocs calendar colors.constants
combinators combinators.short-circuit destructors formatting fry
images.loader kernel locals math math.order math.parser
namespaces opengl opengl.textures random sequences timers ui
ui.commands ui.gadgets ui.gadgets.toolbar ui.gadgets.tracks
ui.gadgets.worlds ui.gestures ui.pens.solid ui.render words ;

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

: unmined-cell ( cells -- cell )
    f [ dup mined?>> ] [ drop dup random random ] do while nip ;

: #mines ( cells -- n )
    [ [ mined?>> ] count ] map-sum ;

: #flagged ( cells -- n )
    [ [ state>> +flagged+ = ] count ] map-sum ;

: #mines-remaining ( cells -- n )
    [ #mines ] [ #flagged ] bi - ;

: place-mines ( cells n -- cells )
    [ dup unmined-cell t >>mined? drop ] times ;

: adjacent-mines ( cells row col -- #mines )
    neighbors [
        first2 [ + ] bi-curry@ bi* cell-at
        [ mined?>> ] [ f ] if*
    ] with with with count ;

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
    [ [ state>> +clicked+ = ] any? ] any? not ;

DEFER: click-cell-at

:: click-cells-around ( cells row col -- )
    neighbors [
        first2 [ row + ] [ col + ] bi* :> ( row' col' )
        cells row' col' cell-at [
            { [ mined?>> ] [ state>> +question+ = ] } 1|| [
                cells row' col' click-cell-at drop
            ] unless
        ] when*
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

TUPLE: grid-gadget < gadget cells timer textures start end ;

:: <grid-gadget> ( rows cols mines -- gadget )
    grid-gadget new
        rows cols make-cells
        mines place-mines update-counts >>cells
        H{ } clone >>textures
        dup '[ _ relayout-1 ] f 1 seconds <timer> >>timer
        COLOR: gray <solid> >>interior ;

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

:: cell-image-path ( cell game-over? -- image-path )
    game-over? cell mined?>> and [
        cell state>> +clicked+ = "mineclicked.gif" "mine.gif" ?
    ] [
        cell state>>
        {
            { +question+ [ "question.gif" ] }
            { +flagged+ [ game-over? "misflagged.gif" "flagged.gif" ? ] }
            { +clicked+ [
                cell mined?>> [
                    "mine.gif"
                ] [
                    cell #adjacent>> 0 or number>string
                    "open" ".gif" surround
                ] if ] }
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

: cached-texture ( path gadget -- texture )
    textures>> [ load-image { 0 0 } <texture> ] cache ;

:: draw-mines ( n gadget -- )
    n "%03d" sprintf [
        26 * 3 + 6 2array [
            digit-image-path gadget cached-texture
            { 26 46 } swap draw-scaled-texture
        ] with-translation
    ] each-index ;

:: draw-smiley ( gadget -- )
    gadget pref-dim first :> width
    width 2/ 26 - 3 2array [
        gadget cells>> won?
        gadget cells>> lost?
        hand-buttons get-global empty? not
        gadget hand-click-rel second 58 >= and
        smiley-image-path
        gadget cached-texture { 52 52 } swap draw-scaled-texture
    ] with-translation ;

:: draw-timer ( n gadget -- )
    gadget pref-dim first :> width
    n "%03d" sprintf [
        3 swap - 26 * width swap - 3 - 6 2array [
            digit-image-path gadget cached-texture
            { 26 46 } swap draw-scaled-texture
        ] with-translation
    ] each-index ;

:: draw-cells ( gadget -- )
    gadget cells>> game-over? :> game-over?
    gadget cells>> [| row col cell |
        col row [ 32 * ] bi@ 58 + 2array [
            cell game-over? cell-image-path
            gadget cached-texture
            { 32 32 } swap draw-scaled-texture
        ] with-translation
    ] each-cell ;

:: elapsed-time ( gadget -- n )
    gadget start>> [
        gadget end>> now or swap time- duration>seconds
    ] [ 0 ] if* ;

M: grid-gadget draw-gadget*
    {
        [ cells>> #mines-remaining ]
        [ draw-mines ]
        [ draw-smiley ]
        [ elapsed-time ]
        [ draw-timer ]
        [ draw-cells ]
    } cleave ;

:: on-click ( gadget -- )
    gadget hand-rel first2 :> ( w h )
    h 58 < [
        h 3 55 between?
        gadget pref-dim first 2/ w - abs 26 < and [
            gadget [ reset-cells ] change-cells
            f >>start f >>end relayout-1
        ] when
    ] [
        h 58 - w [ 32 /i ] bi@ :> ( row col )
        gadget cells>> :> cells
        cells game-over? [
            cells row col click-cell-at [
                gadget start>> [ now gadget start<< ] unless
                cells game-over? [ now gadget end<< ] when
                gadget relayout-1
            ] when
        ] unless
    ] if ;

:: on-mark ( gadget -- )
    gadget hand-rel first2 :> ( w h )
    h 58 >= [
        h 58 - w [ 32 /i ] bi@ :> ( row col )
        gadget cells>> :> cells
        cells game-over? [
            cells row col mark-cell-at [
                gadget start>> [ now gadget start<< ] unless
                cells game-over? [ now gadget end<< ] when
                gadget relayout-1
            ] when
        ] unless
    ] when ;

: new-game ( gadget rows cols mines -- )
    [ make-cells ] dip place-mines update-counts >>cells
    f >>start f >>end relayout-window ;

: com-easy ( gadget -- ) 7 7 10 new-game ;

: com-medium ( gadget -- ) 15 15 40 new-game ;

: com-hard ( gadget -- ) 15 30 99 new-game ;

grid-gadget "toolbar" f {
    { T{ key-down { sym "1" } } com-easy }
    { T{ key-down { sym "2" } } com-medium }
    { T{ key-down { sym "3" } } com-hard }
} define-command-map

grid-gadget "gestures" [
    {
        { T{ button-down { # 1 } } [ relayout-1 ] }
        { T{ button-up { # 1 } } [ on-click ] }
        { T{ button-up { # 3 } } [ on-mark ] }
        { T{ key-down { sym " " } } [ on-mark ] }
    } assoc-union
] change-word-prop

TUPLE: minesweeper-gadget < track ;

: <minesweeper-gadget> ( -- gadget )
    vertical minesweeper-gadget new-track
    7 7 10 <grid-gadget>
    [ <toolbar> format-toolbar f track-add ]
    [ 1 track-add ] bi ;

M: minesweeper-gadget focusable-child* children>> second ;

MAIN-WINDOW: run-minesweeper {
        { title "Minesweeper" }
        { window-controls
            { normal-title-bar close-button minimize-button } }
    } <minesweeper-gadget> >>gadgets ;
