! Copyright (C) 2006, 2009 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alarms arrays assocs calendar colors.constants
combinators combinators.short-circuit documents
documents.elements fry grouping kernel locals make math
math.functions math.order math.ranges math.rectangles
math.vectors models models.arrow namespaces opengl sequences
sorting splitting ui.baseline-alignment ui.clipboards
ui.commands ui.gadgets ui.gadgets.borders
ui.gadgets.line-support ui.gadgets.menus ui.gadgets.scrollers
ui.gestures ui.pens.solid ui.render ui.text unicode.categories ;
EXCLUDE: fonts => selection ;
IN: ui.gadgets.editors

TUPLE: editor < line-gadget
caret-color
caret mark
focused? blink blink-alarm ;

<PRIVATE

: <loc> ( -- loc ) { 0 0 } <model> ;

: init-editor-locs ( editor -- editor )
    <loc> >>caret
    <loc> >>mark ; inline

: editor-theme ( editor -- editor )
    COLOR: red >>caret-color
    monospace-font >>font ; inline

PRIVATE>

: new-editor ( class -- editor )
    new-line-gadget
        <document> >>model
        init-editor-locs
        editor-theme ; inline

: <editor> ( -- editor )
    editor new-editor ;

<PRIVATE

: activate-editor-model ( editor model -- )
    [ add-connection ]
    [ nip activate-model ]
    [ swap model>> add-loc ] 2tri ;

: deactivate-editor-model ( editor model -- )
    [ remove-connection ]
    [ nip deactivate-model ]
    [ swap model>> remove-loc ] 2tri ;

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

PRIVATE>

M: editor graft*
    [ dup caret>> activate-editor-model ]
    [ dup mark>> activate-editor-model ] bi ;

M: editor ungraft*
    [ stop-blinking ]
    [ dup caret>> deactivate-editor-model ]
    [ dup mark>> deactivate-editor-model ] tri ;

: editor-caret ( editor -- loc ) caret>> value>> ;

: editor-mark ( editor -- loc ) mark>> value>> ;

: set-caret ( loc editor -- )
    [ model>> validate-loc ] [ caret>> ] bi set-model ;

: change-caret ( editor quot -- )
    [ [ [ editor-caret ] [ model>> ] bi ] dip call ] [ drop ] 2bi
    set-caret ; inline

: mark>caret ( editor -- )
    [ editor-caret ] [ mark>> ] bi set-model ;

: change-caret&mark ( editor quot -- )
    [ change-caret ] [ drop mark>caret ] 2bi ; inline

: editor-line ( n editor -- str ) control-value nth ;

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
    [ first2 swap ] dip [ editor-line ] [ font>> ] bi swap offset>x round ;

: loc>point ( loc editor -- loc )
    [ loc>x ] [ [ first ] dip line>y ceiling ] 2bi 2array ;

: caret-loc ( editor -- loc )
    [ editor-caret ] keep loc>point ;

: caret-dim ( editor -- dim )
    [ 0 ] dip line-height 2array ;

: scroll>caret ( editor -- )
    dup graft-state>> second [
        [
            [ caret-loc ] [ caret-dim { 2 1 } v+ ] bi <rect>
        ] keep scroll>rect
    ] [ drop ] if ;

<PRIVATE

: draw-caret? ( editor -- ? )
    { [ focused?>> ] [ blink>> ] } 1&& ;

: draw-caret ( editor -- )
    dup draw-caret? [
        [ caret-color>> gl-color ]
        [
            [ caret-loc ] [ caret-dim ] bi
            over v+ gl-line
        ] bi
    ] [ drop ] if ;

: selection-start/end ( editor -- start end )
    [ editor-mark ] [ editor-caret ] bi sort-pair ;

SYMBOL: selected-lines

TUPLE: selected-line start end first? last? ;

: compute-selection ( editor -- assoc )
    dup gadget-selection? [
        [ selection-start/end [ [ first ] bi@ [a,b] ] [ ] 2bi ]
        [ model>> ] bi
        '[ [ _ _ ] [ _ start/end-on-line ] bi 2array ] H{ } map>assoc
    ] [ drop f ] if ;

:: draw-selection ( line pair editor -- )
    pair [ editor font>> line offset>x ] map :> pair
    editor selection-color>> gl-color
    pair first 0 2array
    pair second pair first - round 1 max editor line-height 2array
    gl-fill-rect ;

: draw-unselected-line ( line editor -- )
    font>> swap draw-text ;

: draw-selected-line ( line pair editor -- )
    over all-equal? [
        [ nip draw-unselected-line ] [ draw-selection ] 3bi
    ] [
        [ draw-selection ]
        [
            [ [ first2 ] [ selection-color>> ] bi* <selection> ]
            [ draw-unselected-line ] bi
        ] 3bi
    ] if ;

PRIVATE>

M: editor draw-line ( line index editor -- )
    [ selected-lines get at ] dip over
    [ draw-selected-line ] [ nip draw-unselected-line ] if ;

M: editor draw-gadget*
    dup compute-selection selected-lines [
        [ draw-lines ] [ draw-caret ] bi
    ] with-variable ;

M: editor pref-dim*
    ! Add some space for the caret.
    [ font>> ] [ control-value ] bi text-dim { 1 0 } v+ ;

M: editor baseline font>> font-metrics ascent>> ;

M: editor cap-height font>> font-metrics cap-height>> ;

<PRIVATE

: contents-changed ( model editor -- )
    [ [ nip caret>> ] [ drop ] 2bi '[ _ validate-loc ] (change-model) ]
    [ [ nip mark>> ] [ drop ] 2bi '[ _ validate-loc ] (change-model) ]
    [ nip relayout ] 2tri ;

: caret/mark-changed ( editor -- )
    [ restart-blinking ] keep scroll>caret ;

PRIVATE>

M: editor model-changed
    {
        { [ 2dup model>> eq? ] [ contents-changed ] }
        { [ 2dup caret>> eq? ] [ nip caret/mark-changed ] }
        { [ 2dup mark>> eq? ] [ nip caret/mark-changed ] }
    } cond ;

M: editor gadget-selection?
    selection-start/end = not ;

M: editor gadget-selection
    [ selection-start/end ] [ model>> ] bi doc-range ;

: remove-selection ( editor -- )
    [ selection-start/end ] [ model>> ] bi remove-doc-range ;

M: editor user-input*
    [ selection-start/end ] [ model>> ] bi set-doc-range t ;

: editor-string ( editor -- string )
    model>> doc-string ;

: set-editor-string ( string editor -- )
    model>> set-doc-string ;

M: editor gadget-text* editor-string % ;

: extend-selection ( editor -- )
    [ request-focus ]
    [ restart-blinking ]
    [ dup caret>> click-loc ] tri ;

: mouse-elt ( -- element )
    hand-click# get {
        { 1 one-char-elt }
        { 2 one-word-elt }
    } at one-line-elt or ;

: drag-direction? ( loc editor -- ? )
    editor-mark before? ;

: drag-selection-caret ( loc editor element -- loc )
    [
        [ drag-direction? ] [ model>> ] 2bi
    ] dip prev/next-elt ? ;

: drag-selection-mark ( loc editor element -- loc )
    [
        [ drag-direction? not ]
        [ editor-mark ]
        [ model>> ] tri
    ] dip prev/next-elt ? ;

: drag-caret&mark ( editor -- caret mark )
    [ clicked-loc ] [ mouse-elt ] bi
    [ drag-selection-caret ]
    [ drag-selection-mark ] 3bi ;

: drag-selection ( editor -- )
    [ drag-caret&mark ]
    [ mark>> set-model ]
    [ caret>> set-model ] tri ;

: editor-cut ( editor clipboard -- )
    [ gadget-copy ] [ drop remove-selection ] 2bi ;

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
    [ editor-select-prev ] [ drop mark>caret ] 2bi ;

: editor-select-next ( editor elt -- )
    '[ _ next-elt ] change-caret ;

: editor-next ( editor elt -- )
    dupd editor-select-next mark>caret ;

: editor-select ( from to editor -- )
    [ mark>> set-model ] [ caret>> set-model ] bi-curry bi* ;

: select-elt ( editor elt -- )
    [ [ [ editor-caret ] [ model>> ] bi ] dip prev/next-elt ] [ drop ] 2bi
    editor-select ;

: start-of-document ( editor -- ) doc-elt editor-prev ;

: end-of-document ( editor -- ) doc-elt editor-next ;

: position-caret ( editor -- )
    mouse-elt dup one-char-elt =
    [ drop dup extend-selection dup mark>> click-loc ]
    [ select-elt ] if ;

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

: com-undo ( editor -- ) model>> undo ;

: com-redo ( editor -- ) model>> redo ;

editor "editing" f {
    { undo-action com-undo }
    { redo-action com-redo }
    { T{ key-down f f "DELETE" } delete-next-character }
    { T{ key-down f { S+ } "DELETE" } delete-next-character }
    { T{ key-down f f "BACKSPACE" } delete-previous-character }
    { T{ key-down f { S+ } "BACKSPACE" } delete-previous-character }
    { T{ key-down f { C+ } "DELETE" } delete-previous-word }
    { T{ key-down f { C+ } "BACKSPACE" } delete-next-word }
    { T{ key-down f { A+ } "DELETE" } delete-to-start-of-line }
    { T{ key-down f { A+ } "BACKSPACE" } delete-to-end-of-line }
} define-command-map

: com-paste ( editor -- ) clipboard get paste-clipboard ;

: paste-selection ( editor -- ) selection get paste-clipboard ;

: com-cut ( editor -- ) clipboard get editor-cut ;

editor "clipboard" f {
    { cut-action com-cut }
    { copy-action com-copy }
    { paste-action com-paste }
    { T{ button-up } com-copy-selection }
    { T{ button-up f f 2 } paste-selection }
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
    model>> clear-doc ;

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
    { T{ button-up f { S+ } 1 } com-copy-selection }
    { T{ drag } drag-selection }
    { gain-focus focus-editor }
    { lose-focus unfocus-editor }
    { delete-action remove-selection }
    { select-all-action select-all }
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
    {
        com-undo
        com-redo
        ----
        com-cut
        com-copy
        com-paste
    } show-commands-menu ;

editor "misc" f {
    { T{ button-down f f 3 } editor-menu }
} define-command-map

! Multi-line editors
TUPLE: multiline-editor < editor ;

: <multiline-editor> ( -- editor )
    multiline-editor new-editor ;

: previous-line ( editor -- ) line-elt editor-prev ;

: next-line ( editor -- ) line-elt editor-next ;

<PRIVATE

: page-elt ( editor -- editor element ) dup visible-lines 1 - <page-elt> ;

PRIVATE>

: previous-page ( editor -- ) page-elt editor-prev ;

: next-page ( editor -- ) page-elt editor-next ;

: select-previous-line ( editor -- ) line-elt editor-select-prev ;

: select-next-line ( editor -- ) line-elt editor-select-next ;

: select-previous-page ( editor -- ) page-elt editor-select-prev ;

: select-next-page ( editor -- ) page-elt editor-select-next ;

: insert-newline ( editor -- )
    "\n" swap user-input* drop ;

: change-selection ( editor quot -- )
    '[ gadget-selection @ ] [ user-input* drop ] bi ; inline

<PRIVATE

: join-lines ( string -- string' )
    "\n" split
    [ rest-slice [ [ blank? ] trim-head-slice ] map! drop ]
    [ but-last-slice [ [ blank? ] trim-tail-slice ] map! drop ]
    [ " " join ]
    tri ;

: last-line? ( document line -- ? )
    [ last-line# ] dip = ;

: prev-line-and-this ( document line -- start end )
    swap
    [ drop 1 - 0 2array ]
    [ [ drop ] [ doc-line length ] 2bi 2array ]
    2bi ;

: join-with-prev ( document line -- )
    [ prev-line-and-this ] [ drop ] 2bi
    [ join-lines ] change-doc-range ;

: this-line-and-next ( document line -- start end )
    swap
    [ drop 0 2array ]
    [ [ 1 + ] dip [ drop ] [ doc-line length ] 2bi 2array ]
    2bi ;

: join-with-next ( document line -- )
    [ this-line-and-next ] [ drop ] 2bi
    [ join-lines ] change-doc-range ;

PRIVATE>

: com-join-lines ( editor -- )
    dup gadget-selection?
    [ [ join-lines ] change-selection ] [
        [ model>> ] [ editor-caret first ] bi {
            { [ over last-line# 0 = ] [ 2drop ] }
            { [ 2dup last-line? ] [ join-with-prev ] }
            [ join-with-next ]
        } cond
    ] if ;

multiline-editor "multiline" f {
    { T{ key-down f f "UP" } previous-line }
    { T{ key-down f f "DOWN" } next-line }
    { T{ key-down f { S+ } "UP" } select-previous-line }
    { T{ key-down f { S+ } "DOWN" } select-next-line }
    { T{ key-down f f "PAGE_UP" } previous-page }
    { T{ key-down f f "PAGE_DOWN" } next-page }
    { T{ key-down f { S+ } "PAGE_UP" } select-previous-page }
    { T{ key-down f { S+ } "PAGE_DOWN" } select-next-page }
    { T{ key-down f f "RET" } insert-newline }
    { T{ key-down f { S+ } "RET" } insert-newline }
    { T{ key-down f f "ENTER" } insert-newline }
    { T{ key-down f { C+ } "j" } com-join-lines }
} define-command-map

TUPLE: source-editor < multiline-editor ;

: <source-editor> ( -- editor )
    source-editor new-editor ;

! A useful model
: <element-model> ( editor element -- model )
    [ [ caret>> ] [ model>> ] bi ] dip
    '[ _ _ elt-string ] <arrow> ;

! Fields wrap an editor
TUPLE: field < border editor min-cols max-cols ;

<PRIVATE

: field-theme ( gadget -- gadget )
    { 2 2 } >>size
    { 1 0 } >>fill
    COLOR: gray <solid> >>boundary ; inline

: <field-border> ( gadget -- border )
    { 2 2 } <border>
        { 1 0 } >>fill
        field-theme ;

PRIVATE>

: new-field ( class -- gadget )
    [ <editor> ] dip new-border
        dup gadget-child >>editor
        field-theme ; inline

! For line-gadget-width
M: field font>> editor>> font>> ;

M: field pref-dim*
    [ ]
    [ editor>> pref-dim ]
    [ [ line-gadget-width ] [ drop second ] 2bi 2array ]
    tri border-pref-dim ;

TUPLE: model-field < field field-model ;

: <model-field> ( model -- gadget )
    model-field new-field
        swap >>field-model ;

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
    action-field new-field
        swap >>quot ;

: invoke-action-field ( field -- )
    [ editor>> editor-string ]
    [ editor>> clear-editor ]
    [ quot>> ]
    tri call( string -- ) ;

action-field H{
    { T{ key-down f f "RET" } [ invoke-action-field ] }
} set-gestures
