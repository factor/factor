! Copyright (C) 2006, 2007 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: arrays documents ui.clipboards ui.commands ui.gadgets
ui.gadgets.borders ui.gadgets.buttons ui.gadgets.labels
ui.gadgets.scrollers ui.gadgets.theme ui.render ui.gestures io
kernel math models namespaces opengl opengl.gl sequences strings
io.styles math.vectors sorting colors combinators assocs ;
IN: ui.gadgets.editors

TUPLE: editor
self
font color caret-color selection-color
caret mark
focused? ;

: <loc> ( -- loc ) { 0 0 } <model> ;

: init-editor-locs ( editor -- )
    <loc> over set-editor-caret
    <loc> swap set-editor-mark ;

: editor-theme ( editor -- )
    black over set-editor-color
    red over set-editor-caret-color
    selection-color over set-editor-selection-color
    monospace-font swap set-editor-font ;

: <editor> ( -- editor )
    <document> <gadget> editor construct-control
    dup dup set-editor-self
    dup init-editor-locs
    dup editor-theme ;

: field-theme ( gadget -- )
    gray <solid> swap set-gadget-boundary ;

: construct-editor ( class -- tuple )
    >r <editor> { set-gadget-delegate } r> construct
    dup dup set-editor-self ; inline

TUPLE: source-editor ;

: <source-editor> source-editor construct-editor ;

: activate-editor-model ( editor model -- )
    2dup add-connection
    dup activate-model
    swap gadget-model add-loc ;

: deactivate-editor-model ( editor model -- )
    2dup remove-connection
    dup deactivate-model
    swap gadget-model remove-loc ;

M: editor graft*
    dup
    dup editor-caret activate-editor-model
    dup editor-mark activate-editor-model ;

M: editor ungraft*
    dup
    dup editor-caret deactivate-editor-model
    dup editor-mark deactivate-editor-model ;

: editor-caret* ( editor -- loc ) editor-caret model-value ;

: editor-mark* ( editor -- loc ) editor-mark model-value ;

: change-caret ( editor quot -- )
    over >r >r dup editor-caret* swap gadget-model r> call r>
    [ gadget-model validate-loc ] keep
    editor-caret set-model ; inline

: mark>caret ( editor -- )
    dup editor-caret* swap editor-mark set-model ;

: change-caret&mark ( editor quot -- )
    over >r change-caret r> mark>caret ; inline

: editor-line ( n editor -- str ) control-value nth ;

: editor-font* ( editor -- font ) editor-font open-font ;

: line-height ( editor -- n )
    editor-font* "" string-height ;

: y>line ( y editor -- line# )
    [ line-height / >fixnum ] keep gadget-model validate-line ;

: point>loc ( point editor -- loc )
    [
        >r first2 r> tuck y>line dup ,
        >r dup editor-font* r>
        rot editor-line x>offset ,
    ] { } make ;

: clicked-loc ( editor -- loc )
    [ hand-rel ] keep point>loc ;

: click-loc ( editor model -- )
    >r clicked-loc r> set-model ;

: focus-editor ( editor -- )
    t over set-editor-focused? relayout-1 ;

: unfocus-editor ( editor -- )
    f over set-editor-focused? relayout-1 ;

: (offset>x) ( font col# str -- x )
    swap head-slice string-width ;

: offset>x ( col# line# editor -- x )
    [ editor-line ] keep editor-font* -rot (offset>x) ;

: loc>x ( loc editor -- x ) >r first2 swap r> offset>x ;

: line>y ( lines# editor -- y )
    line-height * ;

: caret-loc ( editor -- loc )
    [ editor-caret* ] keep 2dup loc>x
    rot first rot line>y 2array ;

: caret-dim ( editor -- dim )
    line-height 0 swap 2array ;

: scroll>caret ( editor -- )
    dup gadget-graft-state second [
        dup caret-loc over caret-dim { 1 0 } v+ <rect>
        over scroll>rect
    ] when drop ;

: draw-caret ( -- )
    editor get editor-focused? [
        editor get
        dup editor-caret-color gl-color
        dup caret-loc origin get v+
        swap caret-dim over v+
        [ { 0.5 -0.5 } v+ ] 2apply gl-line
    ] when ;

: line-translation ( n -- loc )
    editor get line-height * 0.0 swap 2array ;

: translate-lines ( n -- )
    line-translation gl-translate ;

: draw-line ( editor str -- )
    >r editor-font r> { 0 0 } draw-string ;

: first-visible-line ( editor -- n )
    clip get rect-loc second origin get second -
    swap y>line ;

: last-visible-line ( editor -- n )
    clip get rect-extent nip second origin get second -
    swap y>line 1+ ;

: with-editor ( editor quot -- )
    [
        swap
        dup first-visible-line \ first-visible-line set
        dup last-visible-line \ last-visible-line set
        dup gadget-model document set
        editor set
        call
    ] with-scope ; inline

: visible-lines ( editor -- seq )
    \ first-visible-line get
    \ last-visible-line get
    rot control-value <slice> ;

: with-editor-translation ( n quot -- )
    >r line-translation origin get v+ r> with-translation ;
    inline

: draw-lines ( -- )
    \ first-visible-line get [
        editor get dup editor-color gl-color
        dup visible-lines
        [ draw-line 1 translate-lines ] curry* each
    ] with-editor-translation ;

: selection-start/end ( editor -- start end )
    dup editor-mark* swap editor-caret* sort-pair ;

: (draw-selection) ( x1 x2 -- )
    2dup = [ 2 + ] when
    0.0 swap editor get line-height glRectd ;

: draw-selected-line ( start end n -- )
    [ start/end-on-line ] keep tuck
    >r >r editor get offset>x r> r>
    editor get offset>x
    (draw-selection) ;

: draw-selection ( -- )
    editor get editor-selection-color gl-color
    editor get selection-start/end
    over first [
        2dup [
            >r 2dup r> draw-selected-line
            1 translate-lines
        ] each-line 2drop
    ] with-editor-translation ;

M: editor draw-gadget*
    [ draw-selection draw-lines draw-caret ] with-editor ;

M: editor pref-dim*
    dup editor-font* swap control-value text-dim ;

: contents-changed
    editor-self swap
    over editor-caret [ over validate-loc ] (change-model)
    over editor-mark [ over validate-loc ] (change-model)
    drop relayout ;

: caret/mark-changed
    nip editor-self dup relayout-1 scroll>caret ;

M: editor model-changed
    {
        { [ 2dup gadget-model eq? ] [ contents-changed ] }
        { [ 2dup editor-caret eq? ] [ caret/mark-changed ] }
        { [ 2dup editor-mark eq? ] [ caret/mark-changed ] }
    } cond ;

M: editor gadget-selection?
    selection-start/end = not ;

M: editor gadget-selection
    [ selection-start/end ] keep gadget-model doc-range ;

: remove-selection ( editor -- )
    [ selection-start/end ] keep gadget-model remove-doc-range ;

M: editor user-input*
    [ selection-start/end ] keep gadget-model set-doc-range t ;

: editor-string ( editor -- string )
    gadget-model doc-string ;

: set-editor-string ( string editor -- )
    gadget-model set-doc-string ;

M: editor gadget-text* editor-string % ;

: extend-selection ( editor -- )
    dup request-focus dup editor-caret click-loc ;

: mouse-elt ( -- elelement )
    hand-click# get {
        { 2 T{ one-word-elt } }
        { 3 T{ one-line-elt } }
    } at T{ one-char-elt } or ;

: drag-direction? ( loc editor -- ? )
    editor-mark* <=> 0 < ;

: drag-selection-caret ( loc editor element -- loc )
    >r [ drag-direction? ] 2keep
    gadget-model
    r> prev/next-elt ? ;

: drag-selection-mark ( loc editor element -- loc )
    >r [ drag-direction? not ] 2keep
    nip dup editor-mark* swap gadget-model
    r> prev/next-elt ? ;

: drag-caret&mark ( editor -- caret mark )
    dup clicked-loc swap mouse-elt
    [ drag-selection-caret ] 3keep
    drag-selection-mark ;

: drag-selection ( editor -- )
    dup drag-caret&mark
    pick editor-mark set-model
    swap editor-caret set-model ;

: editor-cut ( editor clipboard -- )
    dupd gadget-copy remove-selection ;

: delete/backspace ( elt editor quot -- )
    over gadget-selection? [
        drop nip remove-selection
    ] [
        over >r >r dup editor-caret* swap gadget-model
        r> call r> gadget-model remove-doc-range
    ] if ; inline

: editor-delete ( editor elt -- )
    swap [ over >r rot next-elt r> swap ] delete/backspace ;

: editor-backspace ( editor elt -- )
    swap [ over >r rot prev-elt r> ] delete/backspace ;

: editor-select-prev ( editor elt -- )
    swap [ rot prev-elt ] change-caret ;

: editor-prev ( editor elt -- )
    dupd editor-select-prev mark>caret ;

: editor-select-next ( editor elt -- )
    swap [ rot next-elt ] change-caret ;

: editor-next ( editor elt -- )
    dupd editor-select-next mark>caret ;

: editor-select ( from to editor -- )
    tuck editor-caret set-model editor-mark set-model ;

: select-elt ( editor elt -- )
    over >r
    >r dup editor-caret* swap gadget-model r> prev/next-elt
    r> editor-select ;

: start-of-document ( editor -- ) T{ doc-elt } editor-prev ;

: end-of-document ( editor -- ) T{ doc-elt } editor-next ;

: selected-word ( editor -- string )
    dup gadget-selection? [
        dup T{ one-word-elt } select-elt
    ] unless gadget-selection ;

: position-caret ( editor -- )
    mouse-elt dup T{ one-char-elt } =
    [ drop dup extend-selection dup editor-mark click-loc ]
    [ select-elt ] if ;

: insert-newline "\n" swap user-input ;

: delete-next-character T{ char-elt } editor-delete ;

: delete-previous-character T{ char-elt } editor-backspace ;

: delete-previous-word T{ word-elt } editor-delete ;

: delete-next-word T{ word-elt } editor-backspace ;

: delete-to-start-of-line T{ one-line-elt } editor-delete ;

: delete-to-end-of-line T{ one-line-elt } editor-backspace ;

editor "general" f {
    { T{ key-down f f "RET" } insert-newline }
    { T{ key-down f { S+ } "RET" } insert-newline }
    { T{ key-down f f "ENTER" } insert-newline }
    { T{ key-down f f "DELETE" } delete-next-character }
    { T{ key-down f { S+ } "DELETE" } delete-next-character }
    { T{ key-down f f "BACKSPACE" } delete-previous-character }
    { T{ key-down f { S+ } "BACKSPACE" } delete-previous-character }
    { T{ key-down f { C+ } "DELETE" } delete-previous-word }
    { T{ key-down f { C+ } "BACKSPACE" } delete-next-word }
    { T{ key-down f { A+ } "DELETE" } delete-to-start-of-line }
    { T{ key-down f { A+ } "BACKSPACE" } delete-to-end-of-line }
} define-command-map

: paste clipboard get paste-clipboard ;

: paste-selection selection get paste-clipboard ;

: cut clipboard get editor-cut ;

editor "clipboard" f {
    { T{ paste-action } paste }
    { T{ button-up f f 2 } paste-selection }
    { T{ copy-action } com-copy }
    { T{ button-up } com-copy-selection }
    { T{ cut-action } cut }
} define-command-map

: previous-character T{ char-elt } editor-prev ;

: next-character T{ char-elt } editor-next ;

: previous-line T{ line-elt } editor-prev ;

: next-line T{ line-elt } editor-next ;

: previous-word T{ word-elt } editor-prev ;

: next-word T{ word-elt } editor-next ;

: start-of-line T{ one-line-elt } editor-prev ;

: end-of-line T{ one-line-elt } editor-next ;

editor "caret-motion" f {
    { T{ button-down } position-caret }
    { T{ key-down f f "LEFT" } previous-character }
    { T{ key-down f f "RIGHT" } next-character }
    { T{ key-down f f "UP" } previous-line }
    { T{ key-down f f "DOWN" } next-line }
    { T{ key-down f { C+ } "LEFT" } previous-word }
    { T{ key-down f { C+ } "RIGHT" } next-word }
    { T{ key-down f f "HOME" } start-of-line }
    { T{ key-down f f "END" } end-of-line }
    { T{ key-down f { C+ } "HOME" } start-of-document }
    { T{ key-down f { C+ } "END" } end-of-document }
} define-command-map

: select-all T{ doc-elt } select-elt ;

: select-line T{ one-line-elt } select-elt ;

: select-word T{ one-word-elt } select-elt ;

: select-previous-character T{ char-elt } editor-select-prev ;

: select-next-character T{ char-elt } editor-select-next ;

: select-previous-line T{ line-elt } editor-select-prev ;

: select-next-line T{ line-elt } editor-select-next ;

: select-previous-word T{ word-elt } editor-select-prev ;

: select-next-word T{ word-elt } editor-select-next ;

: select-start-of-line T{ one-line-elt } editor-select-prev ;

: select-end-of-line T{ one-line-elt } editor-select-next ;

: select-start-of-document T{ doc-elt } editor-select-prev ;

: select-end-of-document T{ doc-elt } editor-select-next ;

editor "selection" f {
    { T{ button-down f { S+ } } extend-selection }
    { T{ drag } drag-selection }
    { T{ gain-focus } focus-editor }
    { T{ lose-focus } unfocus-editor }
    { T{ delete-action } remove-selection }
    { T{ select-all-action } select-all }
    { T{ key-down f { C+ } "l" } select-line }
    { T{ key-down f { S+ } "LEFT" } select-previous-character }
    { T{ key-down f { S+ } "RIGHT" } select-next-character }
    { T{ key-down f { S+ } "UP" } select-previous-line }
    { T{ key-down f { S+ } "DOWN" } select-next-line }
    { T{ key-down f { S+ C+ } "LEFT" } select-previous-line }
    { T{ key-down f { S+ C+ } "RIGHT" } select-next-line }
    { T{ key-down f { S+ } "HOME" } select-start-of-line }
    { T{ key-down f { S+ } "END" } select-end-of-line }
    { T{ key-down f { S+ C+ } "HOME" } select-start-of-document }
    { T{ key-down f { S+ C+ } "END" } select-end-of-document }
} define-command-map

! Fields are like editors except they edit an external model
TUPLE: field model editor ;

: <field-border> ( gadget -- border )
    2 <border>
    { 1 0 } over set-border-fill
    dup field-theme ;

: <field> ( model -- gadget )
    <editor> dup <field-border>
    { set-field-model set-field-editor set-gadget-delegate }
    field construct ;

M: field graft*
    dup field-model model-value
    over field-editor set-editor-string
    dup field-editor gadget-model add-connection ;

M: field ungraft*
    dup field-editor gadget-model remove-connection ;

M: field model-changed
    nip
    dup field-editor editor-string
    swap field-model set-model ;
