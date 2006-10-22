! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-walker
USING: arrays errors gadgets gadgets-buttons
gadgets-listener gadgets-panes gadgets-scrolling gadgets-text
gadgets-tracks gadgets-workspace generic hashtables tools
interpreter io kernel kernel-internals listener math models
namespaces sequences shells threads vectors ;

: <callstack-display> ( model -- )
    [ [ continuation-call callstack. ] when* ]
    "Call stack" <labelled-pane> ;

: <datastack-display> ( model -- )
    [ [ continuation-data stack. ] when* ]
    "Data stack" <labelled-pane> ;

: <retainstack-display> ( model -- )
    [ [ continuation-retain stack. ] when* ]
    "Retain stack" <labelled-pane> ;

: <quotation-display> ( quot -- gadget )
    [ [ first2 callframe. ] when* ]
    "Current quotation" <labelled-pane> ;

TUPLE: walker-gadget model quot ns ;

: update-stacks ( walker -- )
    meta-interp get over walker-gadget-model set-model
    meta-callframe swap walker-gadget-quot set-model ;

: with-walker ( gadget quot -- )
    swap dup walker-gadget-ns
    [ slip update-stacks ] bind ; inline

: walker-command ( gadget quot -- )
    meta-interp pick walker-gadget-ns hash
    [ with-walker ] [ 2drop ] if ; inline

: reset-walker ( walker -- )
    dup H{ } clone swap set-walker-gadget-ns
    update-stacks ;

: walker-step [ step ] walker-command ;
: walker-step-in [ step-in ] walker-command ;
: walker-step-out [ step-out ] walker-command ;
: walker-step-back [ step-back ] walker-command ;

: init-walker-models ( walker -- )
    f <model> over set-walker-gadget-quot
    f <model> swap set-walker-gadget-model ;

: walker-gadget-quot$ gadget get walker-gadget-quot ;
: walker-gadget-model$ gadget get walker-gadget-model ;

C: walker-gadget ( -- gadget )
    dup init-walker-models {
        { [ walker-gadget-quot$ <quotation-display> ] f f 1/6 }
        { [ walker-gadget-model$ <datastack-display> ] f f 1/4 }
        { [ walker-gadget-model$ <retainstack-display> ] f f 1/4 }
        { [ walker-gadget-model$ <callstack-display> ] f f 1/3 }
    } { 0 1 } make-track* ;

M: walker-gadget call-tool* ( continuation walker -- )
    dup reset-walker [
        V{ } clone meta-history set
        restore-normally
    ] with-walker ;

M: walker-gadget tool-help drop "ui-walker" ;

: walker-inspect ( walker -- )
    walker-gadget-ns [ meta-interp get ] bind
    [ inspect ] curry call-listener ;

: walker-step-all ( walker -- )
    dup [ step-all ] walker-command reset-walker
    find-workspace listener-gadget select-tool ;

walker-gadget "toolbar" {
    { "Step" T{ key-down f f "s" } [ walker-step ] }
    { "Step in" T{ key-down f f "i" } [ walker-step-in ] }
    { "Step out" T{ key-down f f "o" } [ walker-step-out ] }
    { "Step back" T{ key-down f f "b" } [ walker-step-back ] }
    { "Continue" T{ key-down f f "c" } [ walker-step-all ] }
    { "Inspect" T{ key-down f f "n" } [ walker-inspect ] }
} define-commands

[ walker-gadget call-tool stop ] break-hook set-global

IN: tools

: walk ( quot -- ) [ break ] swap append call ;
