! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-walker
USING: arrays errors gadgets gadgets-buttons gadgets-frames
gadgets-listener gadgets-panes gadgets-scrolling gadgets-text
gadgets-tracks generic hashtables tools
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
    over walker-gadget-ns [ with-walker ] [ 2drop ] if ; inline

: reset-walker ( walker -- )
    f over set-walker-gadget-ns
    f over walker-gadget-model set-model
    f over walker-gadget-quot set-model ;

: walker-step [ step ] walker-command ;
: walker-step-in [ step-in ] walker-command ;
: walker-step-out [ step-out ] walker-command ;
: walker-step-back [ step-back ] walker-command ;

: init-walker-models ( walker -- model quot )
    f <model> over set-walker-gadget-quot
    f <model> swap set-walker-gadget-model ;

: (walk) ( quot continuation walker -- )
    H{ } clone over set-walker-gadget-ns [
        V{ } clone meta-history set
        meta-interp set
        (meta-call)
    ] with-walker ;

: walker-gadget-quot$ gadget get walker-gadget-quot ;
: walker-gadget-model$ gadget get walker-gadget-model ;

C: walker-gadget ( -- gadget )
    dup init-walker-models {
        { [ walker-gadget-quot$ <quotation-display> ] f f 1/6 }
        { [ walker-gadget-model$ <callstack-display> ] f f 5/18 }
        { [ walker-gadget-model$ <datastack-display> ] f f 5/18 }
        { [ walker-gadget-model$ <retainstack-display> ] f f 5/18 }
    } { 0 1 } make-track* ;
