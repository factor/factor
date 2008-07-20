! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors namespaces kernel parser prettyprint
sequences arrays io math definitions math.vectors assocs refs
ui.gadgets ui.gestures ui.commands ui.gadgets.scrollers
ui.gadgets.buttons ui.gadgets.borders ui.gadgets.tracks
ui.gadgets.editors ;
IN: ui.gadgets.slots

TUPLE: update-object ;

TUPLE: update-slot ;

TUPLE: edit-slot ;

TUPLE: slot-editor < track ref text ;

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
  { 0 1 } slot-editor new-track
    swap >>ref
    dup <toolbar> f track-add*
    <source-editor> >>text
    dup text>> <scroller> 1 track-add*
    dup revert ;
    
M: slot-editor pref-dim* call-next-method { 600 200 } vmin ;

M: slot-editor focusable-child* text>> ;

slot-editor "toolbar" f {
    { T{ key-down f { C+ } "RET" } commit }
    { T{ key-down f { S+ C+ } "RET" } com-eval }
    { f revert }
    { f delete }
    { T{ key-down f f "ESC" } close }
} define-command-map

TUPLE: editable-slot < track printer ref ;

: <edit-button> ( -- gadget )
    "..."
    [ T{ edit-slot } swap send-gesture drop ]
    <roll-button> ;

: display-slot ( gadget editable-slot -- )
  dup clear-track
    swap          1 track-add*
    <edit-button> f track-add*
  drop ;

: update-slot ( editable-slot -- )
    [ [ ref>> get-ref ] [ printer>> ] bi call ] keep
    display-slot ;

: edit-slot ( editable-slot -- )
    [ clear-track ]
    [
        dup ref>> <slot-editor>
        [ 1 track-add* drop ]
        [ [ scroll>gadget ] [ request-focus ] bi* ] 2bi
    ] bi ;

\ editable-slot H{
    { T{ update-slot } [ update-slot ] }
    { T{ edit-slot } [ edit-slot ] }
} set-gestures

: <editable-slot> ( gadget ref -- editable-slot )
    { 1 0 } editable-slot new-track
        swap >>ref
        [ drop <gadget> ] >>printer
        [ display-slot ] keep ;
