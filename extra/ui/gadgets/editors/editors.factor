! Copyright (C) 2006, 2007 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: arrays documents ui.clipboards ui.commands ui.gadgets
ui.gadgets.borders ui.gadgets.buttons ui.gadgets.labels
ui.gadgets.scrollers ui.gadgets.theme ui.gadgets.controls
ui.render ui.gestures io kernel math models namespaces opengl
opengl.gl sequences strings io.styles math.vectors sorting
colors combinators ;
IN: ui.gadgets.editors

TUPLE: editor
font color caret-color selection-color
caret mark
focused? ;

TUPLE: loc-monitor editor ;

: <loc> ( editor -- loc )
    loc-monitor construct-boa
    { 0 0 } <model> [ add-connection ] keep ;

: init-editor-locs ( editor -- )
    dup <loc> over set-editor-caret
    dup <loc> swap set-editor-mark ;

: editor-theme ( editor -- )
    black over set-editor-color
    red over set-editor-caret-color
    selection-color over set-editor-selection-color
    monospace-font swap set-editor-font ;

: <editor> ( -- editor )
    <document> <gadget> editor construct-control
    dup init-editor-locs
    dup editor-theme ;

: field-theme ( gadget -- )
    gray <solid> swap set-gadget-boundary ;

: <field> ( model -- gadget )
    drop
    <editor>
    2 <border>
    { 1 0 } over set-border-fill
    dup field-theme ;

: construct-editor ( class -- tuple )
    >r <editor> { set-gadget-delegate } r>
    (construct-control) ; inline

TUPLE: source-editor ;

: <source-editor> source-editor construct-editor ;

: activate-editor-model ( editor model -- )
    dup activate-model swap control-model add-loc ;

: deactivate-editor-model ( editor model -- )
    dup deactivate-model swap control-model remove-loc ;

M: editor graft*
    dup dup editor-caret activate-editor-model
    dup dup editor-mark activate-editor-model
    dup control-self swap control-model add-connection ;

M: editor ungraft*
    dup dup editor-caret deactivate-editor-model
    dup dup editor-mark deactivate-editor-model
    dup control-self swap control-model remove-connection ;

M: editor model-changed
    control-self dup control-model
    over editor-caret [ over validate-loc ] (change-model)
    over editor-mark [ over validate-loc ] (change-model)
    drop relayout ;

: editor-caret* ( editor -- loc ) editor-caret model-value ;

: editor-mark* ( editor -- loc ) editor-mark model-value ;

: change-caret ( editor quot -- )
    over >r >r dup editor-caret* swap control-model r> call r>
    [ control-model validate-loc ] keep
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
    [ line-height / >fixnum ] keep control-model validate-line ;

: point>loc ( point editor -- loc )
    [
        >r first2 r> tuck y>line dup ,
        >r dup editor-font* r>
        rot editor-line x>offset ,
    ] { } make ;

: click-loc ( editor model -- )
    >r [ hand-rel ] keep point>loc r> set-model ;

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
    dup gadget-grafted? [
        dup caret-loc over caret-dim { 1 0 } v+ <rect>
        over scroll>rect
    ] when drop ;

M: loc-monitor model-changed
    loc-monitor-editor control-self
    dup relayout-1 scroll>caret ;

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
        dup control-model document set
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

M: editor gadget-selection?
    selection-start/end = not ;

M: editor gadget-selection
    [ selection-start/end ] keep control-model doc-range ;

: remove-selection ( editor -- )
    [ selection-start/end ] keep control-model remove-doc-range ;

M: editor user-input*
    [ selection-start/end ] keep control-model set-doc-range t ;

: editor-string ( editor -- string )
    control-model doc-string ;

: set-editor-string ( string editor -- )
    control-model set-doc-string ;

M: editor gadget-text* editor-string % ;

: start-selection ( editor -- )
    dup editor-caret click-loc ;

: extend-selection ( editor -- )
    dup request-focus start-selection ;

: editor-cut ( editor clipboard -- )
    dupd gadget-copy remove-selection ;

: delete/backspace ( elt editor quot -- )
    over gadget-selection? [
        drop nip remove-selection
    ] [
        over >r >r dup editor-caret* swap control-model
        r> call r> control-model remove-doc-range
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
    >r dup editor-caret* swap control-model r> prev/next-elt
    r> editor-select ;

: start-of-document ( editor -- ) T{ doc-elt } editor-prev ;

: end-of-document ( editor -- ) T{ doc-elt } editor-next ;

: selected-word ( editor -- string )
    dup gadget-selection? [
        dup T{ one-word-elt } select-elt
    ] unless gadget-selection ;

: (position-caret) ( editor -- )
    dup extend-selection
    dup editor-mark click-loc ;

: position-caret ( editor -- )
    hand-click# get {
        { 1 [ (position-caret) ] }
        { 2 [ T{ one-word-elt } select-elt ] }
        { 3 [ T{ one-line-elt } select-elt ] }
        [ 2drop ]
    } case ;

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
    { T{ drag } start-selection }
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

! Editors support the stream output protocol
M: editor stream-write1 >r 1string r> stream-write ;

M: editor stream-write
    control-self dup end-of-document user-input ;

M: editor stream-close drop ;

M: editor stream-flush drop ;
