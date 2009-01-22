! Copyright (C) 2006, 2009 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays documents kernel math models models.filter
namespaces locals fry make opengl opengl.gl sequences strings io.styles
math.vectors sorting colors combinators assocs math.order fry
calendar alarms continuations ui.clipboards ui.commands
ui.gadgets ui.gadgets.borders ui.gadgets.buttons
ui.gadgets.labels ui.gadgets.scrollers ui.gadgets.theme
ui.gadgets.menus ui.gadgets.wrappers ui.render ui.text
ui.gestures math.geometry.rect ;
IN: ui.gadgets.editors

TUPLE: editor < gadget
font color caret-color selection-color
caret mark
focused? blink blink-alarm ;

: <loc> ( -- loc ) { 0 0 } <model> ;

: init-editor-locs ( editor -- editor )
    <loc> >>caret
    <loc> >>mark ; inline

: editor-theme ( editor -- editor )
    black >>color
    red >>caret-color
    selection-color >>selection-color
    monospace-font >>font ; inline

: new-editor ( class -- editor )
    new-gadget
        <document> >>model
        init-editor-locs
        editor-theme ; inline

: <editor> ( -- editor )
    editor new-editor ;

: activate-editor-model ( editor model -- )
    2dup add-connection
    dup activate-model
    swap model>> add-loc ;

: deactivate-editor-model ( editor model -- )
    2dup remove-connection
    dup deactivate-model
    swap model>> remove-loc ;

: blink-caret ( editor -- )
    [ not ] change-blink relayout-1 ;

SYMBOL: blink-interval

750 milliseconds blink-interval set-global

: stop-blinking ( editor -- )
    [ [ cancel-alarm ] when* f ] change-blink-alarm drop ;

: start-blinking ( editor -- )
    [ stop-blinking ] [
        t >>blink
        dup '[ _ blink-caret ] blink-interval get every
        >>blink-alarm drop
    ] bi ;

: restart-blinking ( editor -- )
    dup focused?>> [
        [ start-blinking ]
        [ relayout-1 ]
        bi
    ] [ drop ] if ;

M: editor graft*
    dup
    dup caret>> activate-editor-model
    dup mark>> activate-editor-model ;

M: editor ungraft*
    dup
    dup stop-blinking
    dup caret>> deactivate-editor-model
    dup mark>> deactivate-editor-model ;

: editor-caret ( editor -- loc ) caret>> value>> ;

: editor-mark ( editor -- loc ) mark>> value>> ;

: set-caret ( loc editor -- )
    [ model>> validate-loc ] keep
    caret>> set-model ;

: change-caret ( editor quot -- )
    [ [ [ editor-caret ] [ model>> ] bi ] dip call ] [ drop ] 2bi
    set-caret ; inline

: mark>caret ( editor -- )
    [ editor-caret ] [ mark>> ] bi set-model ;

: change-caret&mark ( editor quot -- )
    [ change-caret ] [ drop mark>caret ] 2bi ; inline

: editor-line ( n editor -- str ) control-value nth ;

: line-height ( editor -- n )
    font>> "" text-height ;

: y>line ( y editor -- line# )
    line-height /i ;

:: point>loc ( point editor -- loc )
    point second editor y>line {
        { [ dup 0 < ] [ drop { 0 0 } ] }
        { [ dup editor model>> last-line# > ] [ drop editor model>> doc-end ] }
        [| n |
            n
            point first
            editor font>>
            n editor editor-line
            x>offset 2array
        ]
    } cond ;

: clicked-loc ( editor -- loc )
    [ hand-rel ] keep point>loc ;

: click-loc ( editor model -- )
    [ clicked-loc ] dip set-model ;

: focus-editor ( editor -- )
    [ start-blinking ] [ t >>focused? relayout-1 ] bi ;

: unfocus-editor ( editor -- )
    [ stop-blinking ] [ f >>focused? relayout-1 ] bi ;

: loc>x ( loc editor -- x )
    [ first2 swap ] dip [ editor-line ] [ font>> ] bi swap offset>x ;

: line>y ( lines# editor -- y )
    line-height * ;

: loc>point ( loc editor -- loc )
    [ loc>x ] [ [ first ] dip line>y ] 2bi 2array ;

: caret-loc ( editor -- loc )
    [ editor-caret ] keep loc>point ;

: caret-dim ( editor -- dim )
    line-height 0 swap 2array ;

: scroll>caret ( editor -- )
    dup graft-state>> second [
        [
            [ caret-loc ] [ caret-dim { 1 0 } v+ ] bi <rect>
        ] keep scroll>rect
    ] [ drop ] if ;

: draw-caret ( -- )
    editor get [ focused?>> ] [ blink>> ] bi and [
        editor get
        [ caret-color>> gl-color ]
        [
            dup caret-loc origin get v+
            swap caret-dim over v+
            gl-line
        ] bi
    ] when ;

: line-translation ( n -- loc )
    editor get line-height * 0.0 swap 2array ;

: translate-lines ( n -- )
    line-translation gl-translate ;

: draw-line ( editor str -- )
    [ font>> ] dip { 0 0 } draw-text ;

: first-visible-line ( editor -- n )
    [
        [ clip get rect-loc second origin get second - ] dip
        y>line
    ] keep model>> validate-line ;

: last-visible-line ( editor -- n )
    [
        [ clip get rect-extent nip second origin get second - ] dip
        y>line
    ] keep model>> validate-line 1+ ;

: with-editor ( editor quot -- )
    [
        swap
        dup first-visible-line \ first-visible-line set
        dup last-visible-line \ last-visible-line set
        dup model>> document set
        editor set
        call
    ] with-scope ; inline

: visible-lines ( editor -- seq )
    [ \ first-visible-line get \ last-visible-line get ] dip
    control-value <slice> ;

: with-editor-translation ( n quot -- )
    [ line-translation origin get v+ ] dip with-translation ;
    inline

: draw-lines ( -- )
    \ first-visible-line get [
        editor get dup color>> gl-color
        dup visible-lines
        [ draw-line 1 translate-lines ] with each
    ] with-editor-translation ;

: selection-start/end ( editor -- start end )
    [ editor-mark ] [ editor-caret ] bi sort-pair ;

: (draw-selection) ( x1 x2 -- )
    over - 1+
    dup 0 = [ 1+ ] when
    [ 0.0 2array ] [ editor get line-height 2array ] bi*
    swap [ gl-fill-rect ] with-translation ;

: draw-selected-line ( start end n -- )
    [ start/end-on-line ] keep
    tuck [ swap 2array editor get loc>x ] 2bi@
    (draw-selection) ;

: draw-selection ( -- )
    editor get selection-color>> gl-color
    editor get selection-start/end
    over first [
        2dup '[
            [ _ _ ] dip
            draw-selected-line
            1 translate-lines
        ] each-line
    ] with-editor-translation ;

M: editor draw-gadget*
    [ draw-selection draw-lines draw-caret ] with-editor ;

M: editor pref-dim*
    [ font>> ] [ control-value ] bi text-dim ;

: contents-changed ( model editor -- )
    swap
    over caret>> [ over validate-loc ] (change-model)
    over mark>> [ over validate-loc ] (change-model)
    drop relayout ;

: caret/mark-changed ( model editor -- )
    nip [ restart-blinking ] [ scroll>caret ] bi ;

M: editor model-changed
    {
        { [ 2dup model>> eq? ] [ contents-changed ] }
        { [ 2dup caret>> eq? ] [ caret/mark-changed ] }
        { [ 2dup mark>> eq? ] [ caret/mark-changed ] }
    } cond ;

M: editor gadget-selection?
    selection-start/end = not ;

M: editor gadget-selection
    [ selection-start/end ] keep model>> doc-range ;

: remove-selection ( editor -- )
    [ selection-start/end ] keep model>> remove-doc-range ;

M: editor user-input*
    [ selection-start/end ] keep model>> set-doc-range t ;

: editor-string ( editor -- string )
    model>> doc-string ;

: set-editor-string ( string editor -- )
    model>> set-doc-string ;

M: editor gadget-text* editor-string % ;

: extend-selection ( editor -- )
    dup request-focus
    dup restart-blinking
    dup caret>> click-loc ;

: mouse-elt ( -- element )
    hand-click# get {
        { 1 one-char-elt }
        { 2 one-word-elt }
    } at one-line-elt or ;

: drag-direction? ( loc editor -- ? )
    editor-mark before? ;

: drag-selection-caret ( loc editor element -- loc )
    [
        [ drag-direction? ] 2keep model>>
    ] dip prev/next-elt ? ;

: drag-selection-mark ( loc editor element -- loc )
    [
        [ drag-direction? not ] keep
        [ editor-mark ] [ model>> ] bi
    ] dip prev/next-elt ? ;

: drag-caret&mark ( editor -- caret mark )
    dup clicked-loc swap mouse-elt
    [ drag-selection-caret ] 3keep
    drag-selection-mark ;

: drag-selection ( editor -- )
    dup drag-caret&mark
    pick mark>> set-model
    swap caret>> set-model ;

: editor-cut ( editor clipboard -- )
    dupd gadget-copy remove-selection ;

: delete/backspace ( editor quot -- )
    over gadget-selection? [
        drop remove-selection
    ] [
        [ [ [ editor-caret ] [ model>> ] bi ] dip call ]
        [ drop model>> ]
        2bi remove-doc-range
    ] if ; inline

: editor-delete ( editor elt -- )
    '[ dupd _ next-elt ] delete/backspace ;

: editor-backspace ( editor elt -- )
    '[ over [ _ prev-elt ] dip ] delete/backspace ;

: editor-select-prev ( editor elt -- )
    '[ _ prev-elt ] change-caret ;

: editor-prev ( editor elt -- )
    dupd editor-select-prev mark>caret ;

: editor-select-next ( editor elt -- )
    '[ _ next-elt ] change-caret ;

: editor-next ( editor elt -- )
    dupd editor-select-next mark>caret ;

: editor-select ( from to editor -- )
    tuck caret>> set-model mark>> set-model ;

: select-elt ( editor elt -- )
    [ [ [ editor-caret ] [ model>> ] bi ] dip prev/next-elt ] [ drop ] 2bi
    editor-select ;

: start-of-document ( editor -- ) doc-elt editor-prev ;

: end-of-document ( editor -- ) doc-elt editor-next ;

: position-caret ( editor -- )
    mouse-elt dup one-char-elt =
    [ drop dup extend-selection dup mark>> click-loc ]
    [ select-elt ] if ;

: insert-newline ( editor -- ) "\n" swap user-input* drop ;

: delete-next-character ( editor -- ) 
    char-elt editor-delete ;

: delete-previous-character ( editor -- ) 
    char-elt editor-backspace ;

: delete-previous-word ( editor -- ) 
    word-elt editor-delete ;

: delete-next-word ( editor -- ) 
    word-elt editor-backspace ;

: delete-to-start-of-line ( editor -- ) 
    one-line-elt editor-delete ;

: delete-to-end-of-line ( editor -- ) 
    one-line-elt editor-backspace ;

editor "general" f {
    { T{ key-down f f "DELETE" } delete-next-character }
    { T{ key-down f { S+ } "DELETE" } delete-next-character }
    { T{ key-down f f "BACKSPACE" } delete-previous-character }
    { T{ key-down f { S+ } "BACKSPACE" } delete-previous-character }
    { T{ key-down f { C+ } "DELETE" } delete-previous-word }
    { T{ key-down f { C+ } "BACKSPACE" } delete-next-word }
    { T{ key-down f { A+ } "DELETE" } delete-to-start-of-line }
    { T{ key-down f { A+ } "BACKSPACE" } delete-to-end-of-line }
} define-command-map

: paste ( editor -- ) clipboard get paste-clipboard ;

: paste-selection ( editor -- ) selection get paste-clipboard ;

: cut ( editor -- ) clipboard get editor-cut ;

editor "clipboard" f {
    { T{ paste-action } paste }
    { T{ button-up f f 2 } paste-selection }
    { T{ copy-action } com-copy }
    { T{ button-up } com-copy-selection }
    { T{ cut-action } cut }
} define-command-map

: previous-character ( editor -- )
    dup gadget-selection? [
        dup selection-start/end drop
        over set-caret mark>caret
    ] [
        char-elt editor-prev
    ] if ;

: next-character ( editor -- )
    dup gadget-selection? [
        dup selection-start/end nip
        over set-caret mark>caret
    ] [
        char-elt editor-next
    ] if ;

: previous-line ( editor -- ) line-elt editor-prev ;

: next-line ( editor -- ) line-elt editor-next ;

: previous-word ( editor -- ) word-elt editor-prev ;

: next-word ( editor -- ) word-elt editor-next ;

: start-of-line ( editor -- ) one-line-elt editor-prev ;

: end-of-line ( editor -- ) one-line-elt editor-next ;

editor "caret-motion" f {
    { T{ button-down } position-caret }
    { T{ key-down f f "LEFT" } previous-character }
    { T{ key-down f f "RIGHT" } next-character }
    { T{ key-down f { C+ } "LEFT" } previous-word }
    { T{ key-down f { C+ } "RIGHT" } next-word }
    { T{ key-down f f "HOME" } start-of-line }
    { T{ key-down f f "END" } end-of-line }
    { T{ key-down f { C+ } "HOME" } start-of-document }
    { T{ key-down f { C+ } "END" } end-of-document }
} define-command-map

: clear-editor ( editor -- )
    #! The with-datastack is a kludge to make it infer. Stupid.
    model>> 1array [ clear-doc ] with-datastack drop ;

: select-all ( editor -- ) doc-elt select-elt ;

: select-line ( editor -- ) one-line-elt select-elt ;

: select-word ( editor -- ) one-word-elt select-elt ;

: selected-token ( editor -- string )
    dup gadget-selection?
    [ dup select-word ] unless
    gadget-selection ;

: select-previous-character ( editor -- ) 
    char-elt editor-select-prev ;

: select-next-character ( editor -- ) 
    char-elt editor-select-next ;

: select-previous-line ( editor -- ) 
    line-elt editor-select-prev ;

: select-next-line ( editor -- ) 
    line-elt editor-select-next ;

: select-previous-word ( editor -- ) 
    word-elt editor-select-prev ;

: select-next-word ( editor -- ) 
    word-elt editor-select-next ;

: select-start-of-line ( editor -- ) 
    one-line-elt editor-select-prev ;

: select-end-of-line ( editor -- ) 
    one-line-elt editor-select-next ;

: select-start-of-document ( editor -- ) 
    doc-elt editor-select-prev ;

: select-end-of-document ( editor -- ) 
    doc-elt editor-select-next ;

editor "selection" f {
    { T{ button-down f { S+ } 1 } extend-selection }
    { T{ drag } drag-selection }
    { T{ gain-focus } focus-editor }
    { T{ lose-focus } unfocus-editor }
    { T{ delete-action } remove-selection }
    { T{ select-all-action } select-all }
    { T{ key-down f { C+ } "l" } select-line }
    { T{ key-down f { S+ } "LEFT" } select-previous-character }
    { T{ key-down f { S+ } "RIGHT" } select-next-character }
    { T{ key-down f { S+ C+ } "LEFT" } select-previous-word }
    { T{ key-down f { S+ C+ } "RIGHT" } select-next-word }
    { T{ key-down f { S+ } "HOME" } select-start-of-line }
    { T{ key-down f { S+ } "END" } select-end-of-line }
    { T{ key-down f { S+ C+ } "HOME" } select-start-of-document }
    { T{ key-down f { S+ C+ } "END" } select-end-of-document }
} define-command-map

: editor-menu ( editor -- )
    { cut com-copy paste } show-commands-menu ;

editor "misc" f {
    { T{ button-down f f 3 } editor-menu }
} define-command-map

! Multi-line editors
TUPLE: multiline-editor < editor ;

: <multiline-editor> ( -- editor )
    multiline-editor new-editor ;

multiline-editor "multiline" f {
    { T{ key-down f f "UP" } previous-line }
    { T{ key-down f f "DOWN" } next-line }
    { T{ key-down f { S+ } "UP" } select-previous-line }
    { T{ key-down f { S+ } "DOWN" } select-next-line }
    { T{ key-down f f "RET" } insert-newline }
    { T{ key-down f { S+ } "RET" } insert-newline }
    { T{ key-down f f "ENTER" } insert-newline }
} define-command-map

TUPLE: source-editor < multiline-editor ;

: <source-editor> ( -- editor )
    source-editor new-editor ;

! A useful model
: <element-model> ( editor element -- model )
    [ [ caret>> ] [ model>> ] bi ] dip
    '[ _ _ elt-string ] <filter> ;

! Fields wrap an editor
TUPLE: field < wrapper editor min-width max-width ;

: field-theme ( gadget -- gadget )
    gray <solid> >>boundary ; inline

: <field-border> ( gadget -- border )
    2 <border>
        { 1 0 } >>fill
        field-theme ;

: new-field ( class -- gadget )
    [ <editor> dup <field-border> ] dip new-wrapper swap >>editor ; inline

: column-width ( editor n -- width )
    [ editor>> font>> ] [ CHAR: \s <string> ] bi* text-width ;

M: field pref-dim*
    [ call-next-method ]
    [ dup min-width>> dup [ column-width 0 2array vmax ] [ 2drop ] if ]
    [ dup max-width>> dup [ column-width 1/0. 2array vmin ] [ 2drop ] if ]
    tri ;

TUPLE: model-field < field field-model ;

: <model-field> ( model -- gadget )
    model-field new-field swap >>field-model ;

M: model-field graft*
    [ [ field-model>> value>> ] [ editor>> ] bi set-editor-string ]
    [ dup editor>> model>> add-connection ]
    bi ;

M: model-field ungraft*
    dup editor>> model>> remove-connection ;

M: model-field model-changed
    nip [ editor>> editor-string ] [ field-model>> ] bi set-model ;

TUPLE: action-field < field quot ;

: <action-field> ( quot -- gadget )
    action-field new-field swap >>quot ;

: invoke-action-field ( field -- )
    [ editor>> editor-string ]
    [ editor>> clear-editor ]
    [ quot>> ]
    tri call ;

action-field H{
    { T{ key-down f f "RET" } [ invoke-action-field ] }
} set-gestures
