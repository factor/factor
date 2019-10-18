! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces ui.gadgets ui.gestures ui.commands kernel
ui.gadgets.scrollers parser prettyprint ui.gadgets.buttons
sequences arrays ui.gadgets.borders ui.gadgets.tracks
ui.gadgets.editors ui.gadgets.controls io math
definitions math.vectors assocs refs ;
IN: ui.gadgets.slots

TUPLE: update-object ;

TUPLE: update-slot ;

TUPLE: edit-slot ;

TUPLE: slot-editor ref text ;

: revert ( slot-editor -- )
    dup slot-editor-ref get-ref unparse-use
    swap slot-editor-text set-editor-string ;

\ revert H{
    { +description+ "Revert any uncomitted changes." }
} define-command

GENERIC: finish-editing ( slot-editor ref -- )

M: key-ref finish-editing
    drop T{ update-object } swap send-gesture drop ;

M: value-ref finish-editing
    drop T{ update-slot } swap send-gesture drop ;

: slot-editor-value ( slot-editor -- object )
    slot-editor-text control-value parse-fresh ;

: commit ( slot-editor -- )
    dup slot-editor-text control-value parse-fresh first
    over slot-editor-ref set-ref
    dup slot-editor-ref finish-editing ;

\ commit H{
    { +description+ "Parse the object being edited, and store the result back into the edited slot." }
} define-command

: com-eval ( slot-editor -- )
    [ slot-editor-text editor-string eval ] keep
    [ slot-editor-ref set-ref ] keep
    dup slot-editor-ref finish-editing ;

\ com-eval H{
    { +listener+ t }
    { +description+ "Parse code which evaluates to an object, and store the result back into the edited slot." }
} define-command

: delete ( slot-editor -- )
    dup slot-editor-ref delete-ref
    T{ update-object } swap send-gesture drop ;

\ delete H{
    { +description+ "Delete the slot and close the slot editor." }
} define-command

: close ( slot-editor -- )
    T{ update-slot } swap send-gesture drop ;

\ close H{
    { +description+ "Close the slot editor without saving changes." }
} define-command

: <slot-editor> ( ref -- gadget )
    slot-editor construct-empty
    [ set-slot-editor-ref ] keep
    [
        toolbar,
        <source-editor> g-> set-slot-editor-text
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

TUPLE: editable-slot printer ref ;

: <edit-button> ( -- gadget )
    "..."
    [ T{ edit-slot } swap send-gesture drop ]
    <roll-button> ;

: display-slot ( gadget editable-slot -- )
    dup clear-track
    [ 1 track, <edit-button> f track, ] with-gadget ;

: update-slot ( editable-slot -- )
    [
        dup editable-slot-ref get-ref
        swap editable-slot-printer call
    ] keep
    [ display-slot ] keep
    scroll>gadget ;

: edit-slot ( editable-slot -- )
    dup clear-track dup [
        dup editable-slot-ref <slot-editor> 1 track,
    ] with-gadget scroll>gadget ;

\ editable-slot H{
    { T{ update-slot } [ update-slot ] }
    { T{ edit-slot } [ edit-slot ] }
} set-gestures

: <editable-slot> ( gadget ref -- editable-slot )
    editable-slot construct-empty
    { 1 0 } <track> over set-gadget-delegate
    [ drop <gadget> ] over set-editable-slot-printer
    [ set-editable-slot-ref ] keep
    [ display-slot ] keep ;
