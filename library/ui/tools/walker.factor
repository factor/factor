! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-walker
USING: gadgets gadgets-buttons gadgets-frames gadgets-listener
gadgets-panes gadgets-scrolling gadgets-tiles gadgets-tracks
generic inspector interpreter io kernel listener math models
namespaces sequences shells threads ;

TUPLE: stack-track ;

C: stack-track ( cs rs ds -- gadget )
    {
        { [ "Data stack"   <stack-tile> ] f f 1/3 }
        { [ "Retain stack" <stack-tile> ] f f 1/3 }
        { [ [ callstack. ] "Call stack" <pane-tile> ] f f 1/3 }
    } { 1 0 } make-track* ;

TUPLE: walker-track pane ;

: <quotation-display> ( quot -- gadget )
    [ [ first2 callframe. ] when* ]
    "Current quotation" <pane-tile> ;

C: walker-track ( cs rs ds quot -- gadget )
    {
        { [ <quotation-display> ] f f 1/6 }
        { [ <stack-track> ] f f 1/6 }
        { [ <input-pane> ] set-walker-track-pane [ <scroller> ] 2/3 }
    } { 0 1 } make-track* ;

TUPLE: walker-gadget track ds rs cs quot ;

: find-walker-gadget [ walker-gadget? ] find-parent ;

: walker-gadget-pane walker-gadget-track walker-track-pane ;

: walker-command ( button word -- )
    unit swap find-walker-gadget walker-gadget-pane pane-call ;

: step ( -- ) next do-1 ;

: into ( -- ) next do ;

: end ( -- ) save-callframe meta-interp continue ;

: <walker-toolbar> ( -- gadget )
    {
        { "Step over" step }
        { "Step into" into }
        { "Continue" end }
    } [
        [
            first2 [ walker-command ] curry <bevel-button> ,
        ] each
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

: walker-listener-hook ( walker -- )
    meta-d get over walker-gadget-ds set-model
    meta-r get over walker-gadget-rs set-model
    meta-c get over walker-gadget-cs set-model
    meta-callframe swap walker-gadget-quot set-model ;

C: walker-gadget ( -- gadget )
    dup init-walker-models {
        { [ <walker-toolbar> ] f f @top }
        { [ walker-models <walker-track> ] set-walker-gadget-track f @center }
    } make-frame* ;

M: walker-gadget gadget-title
    drop "Single stepper" <model> ;

M: walker-gadget pref-dim*
    delegate pref-dim* { 600 600 } vmax ;

M: walker-gadget focusable-child* ( listener -- gadget )
    walker-gadget-pane ;

: walker ( quot continuation -- )
    "walk " listener-prompt set
    set-meta-interp pop-d drop (meta-call)
    clear (listener) end ;

: walker-thread ( quot continuation walker -- )
    dup walker-gadget-pane [
        [ walker-listener-hook ] curry listener-hook set
        walker
    ] with-pane ;

: start-walker ( quot continuation walker -- )
    [ init-namespaces walker-thread ] in-thread 3drop ;

: walk ( quot -- )
    continuation <walker-gadget> dup open-window
    start-walker ;
