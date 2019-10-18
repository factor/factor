! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces gadgets-text gadgets kernel gadgets-scrolling
parser prettyprint gadgets-buttons sequences structure arrays
gadgets-borders gadgets-tracks generic io math definitions
errors ;
IN: gadgets-panes

DEFER: make-pane

IN: gadgets-slots

TUPLE: update-object ;

TUPLE: update-slot ;

TUPLE: edit-slot ;

TUPLE: slot-editor path text ;

: revert ( slot-editor -- )
    dup slot-editor-path field-path unparse-use
    swap slot-editor-text set-editor-string ;

\ revert H{
    { +description+ "Revert any uncomitted changes." }
} define-command

GENERIC: finish-editing ( slot-editor path -- )

M: array finish-editing
    drop T{ update-slot } swap send-gesture drop ;

M: key-path finish-editing
    drop T{ update-object } swap send-gesture drop ;

: slot-editor-value ( slot-editor -- object )
    slot-editor-text control-value parse-fresh ;

: commit ( slot-editor -- )
    dup slot-editor-text control-value parse-fresh first
    over slot-editor-path set-field-path
    dup slot-editor-path finish-editing ;

\ commit H{
    { +description+ "Parse the object being edited, and store the result back into the edited slot." }
} define-command

: com-eval ( slot-editor -- )
    [ slot-editor-text editor-string eval ] keep
    [ slot-editor-path set-field-path ] keep
    dup slot-editor-path finish-editing ;

\ com-eval H{
    { +listener+ t }
    { +description+ "Parse code which evaluates to an object, and store the result back into the edited slot." }
} define-command

: delete ( slot-editor -- )
    dup slot-editor-path
    dup key-path? [ <key-path> ] unless
    dup delete-field-path finish-editing ;

\ delete H{
    { +description+ "Delete the slot and close the slot editor." }
} define-command

: close ( slot-editor -- )
    T{ update-slot } swap send-gesture drop ;

\ close H{
    { +description+ "Close the slot editor without saving changes." }
} define-command

C: slot-editor ( path -- gadget )
    [ set-slot-editor-path ] keep
    [
        toolbar,
        <editor> g-> set-slot-editor-text
        <scroller> 1 track,
    ] { 0 1 } build-track
    dup revert ;

M: slot-editor pref-dim* delegate pref-dim* { 600 200 } vmin ;

slot-editor "toolbar" f {
    { T{ key-down f { C+ } "RET" } commit }
    { T{ key-down f { S+ C+ } "RET" } com-eval }
    { f revert }
    { f delete }
    { T{ key-down f f "ESC" } close }
} define-command-map

TUPLE: editable-slot printer path ;

: <edit-button> ( -- gadget )
    "..."
    [ T{ edit-slot } swap send-gesture drop ]
    <roll-button> ;

: display-slot ( gadget editable-slot -- )
    dup clear-track
    [ 1 track, <edit-button> f track, ] with-gadget ;

: update-slot ( editable-slot -- )
    [
        dup editable-slot-path field-path
        swap editable-slot-printer H{ } make-pane
    ] keep
    [ display-slot ] keep
    scroll>gadget ;

: edit-slot ( editable-slot -- )
    dup clear-track dup [
        dup editable-slot-path <slot-editor> 1 track,
    ] with-gadget scroll>gadget ;

\ editable-slot H{
    { T{ update-slot } [ update-slot ] }
    { T{ edit-slot } [ edit-slot ] }
} set-gestures

C: editable-slot ( gadget path -- editable-slot )
    { 1 0 } <track> over set-gadget-delegate
    [ pprint-short ] over set-editable-slot-printer
    [ set-editable-slot-path ] keep
    [ display-slot ] keep ;
