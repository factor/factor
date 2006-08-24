! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-walker
USING: arrays errors gadgets gadgets-buttons gadgets-frames
gadgets-listener gadgets-panes gadgets-scrolling gadgets-text
gadgets-tiles gadgets-tracks generic hashtables inspector
interpreter io kernel kernel-internals listener math models
namespaces sequences shells threads vectors ;

TUPLE: stack-track ;

C: stack-track ( cs rs ds -- gadget )
    {
        { [ "Data stack"   <stack-tile> ] f f 1/3 }
        { [ "Retain stack" <stack-tile> ] f f 1/3 }
        { [ [ callstack. ] "Call stack" <pane-tile> ] f f 1/3 }
    } { 1 0 } make-track* ;

TUPLE: walker-track pane input ;

: <quotation-display> ( quot -- gadget )
    [ [ first2 callframe. ] when* ] <pane-control> <scroller> ;

: <walker-input> ( -- gadget )
    gadget get walker-track-pane <interactor> ;

C: walker-track ( cs rs ds quot -- gadget )
    {
        { [ <quotation-display> ] f f 1/12 }
        { [ <stack-track> ] f f 3/12 }
        { [ <scrolling-pane> ] set-walker-track-pane [ <scroller> ] 1/2 }
        { [ <walker-input> ] set-walker-track-input [ <scroller> ] 1/6 }
    } { 0 1 } make-track* ;

TUPLE: walker-gadget track ds rs cs quot ns ;

: find-walker-gadget [ walker-gadget? ] find-parent ;

: walker-gadget-pane walker-gadget-track walker-track-pane ;

: walker-gadget-input walker-gadget-track walker-track-input ;

: update-stacks ( walker -- )
    meta-d over walker-gadget-ds set-model
    meta-r over walker-gadget-rs set-model
    meta-c over walker-gadget-cs set-model
    meta-callframe swap walker-gadget-quot set-model ;

: with-walker ( gadget quot -- )
    swap find-walker-gadget
    dup walker-gadget-ns
    [ slip update-stacks ] bind ; inline

: walker-step [ step ] with-walker ;
: walker-step-in [ step-in ] with-walker ;
: walker-step-out [ step-out ] with-walker ;
: walker-step-all [ step-all ] with-walker ;
: walker-step-back [ step-back ] with-walker ;

: <walker-toolbar> ( -- gadget )
    [
        "Step" [ walker-step ] <bevel-button> , 
        "Step in" [ walker-step-in ] <bevel-button> , 
        "Step out" [ walker-step-out ] <bevel-button> , 
        "Continue" [ walker-step-all ] <bevel-button> , 
        "Step back" [ walker-step-back ] <bevel-button> , 
    ] make-toolbar ;

: init-walker-models ( walker -- )
    f <model> over set-walker-gadget-ds
    f <model> over set-walker-gadget-rs
    f <model> over set-walker-gadget-cs
    f <model> swap set-walker-gadget-quot ;

: walker-models ( -- cs rs ds quot )
    gadget get walker-gadget-cs
    gadget get walker-gadget-rs
    gadget get walker-gadget-ds
    gadget get walker-gadget-quot ;

: walker-stream ( walker -- stream )
    dup walker-gadget-input swap walker-gadget-pane
    <duplex-stream> ;

M: walker-gadget gadget-title
    drop "Single stepper" <model> ;

M: walker-gadget pref-dim*
    delegate pref-dim* { 600 600 } vmax ;

M: walker-gadget focusable-child*
    walker-gadget-input ;

: walker-continuation ( -- continuation )
    <empty-continuation>
    catchstack over set-continuation-catch
    namestack over set-continuation-name ;

: init-walker ( walker -- )
    H{ } clone over set-walker-gadget-ns
    walker-continuation swap [
        V{ } clone meta-history set
        meta-interp set
        [ ] (meta-call)
    ] with-walker ;

: walker-call ( quot walker -- )
    [ host-quot ] with-walker ;

: (walk) ( quot walker -- )
    [ meta-call ] with-walker ;

: walker-listener ( walker -- )
    [
        dup init-walker
        dup [ walker-call ] curry eval-hook set
    ] listener ;

: walker-thread ( walker -- )
    [
        init-namespaces
        dup walker-stream [ walker-listener ] with-stream*
    ] in-thread drop ;

C: walker-gadget ( -- gadget )
    dup init-walker-models {
        { [ <walker-toolbar> ] f f @top }
        { [ walker-models <walker-track> ] set-walker-gadget-track f @center }
    } make-frame*
    dup walker-thread ;

\ walker-gadget H{
    { T{ key-down f { C+ } "s" } [ walker-step ] }
    { T{ key-down f { C+ } "n" } [ walker-step-in ] }
    { T{ key-down f { C+ } "o" } [ walker-step-out ] }
    { T{ key-down f { C+ } "r" } [ walker-step-all ] }
    { T{ key-down f { C+ } "b" } [ walker-step-back ] }
} set-gestures

: walker-tool
    [ walker-gadget? ] [ <walker-gadget> ] [ (walk) ] ;

: walk ( quot -- ) walker-tool call-tool ;
