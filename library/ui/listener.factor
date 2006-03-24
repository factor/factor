! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets-listener
USING: arrays gadgets gadgets-editors gadgets-labels
gadgets-layouts gadgets-panes gadgets-scrolling
gadgets-splitters gadgets-theme generic hashtables
io jedit kernel listener lists math
namespaces parser prettyprint sequences threads words ;

TUPLE: listener-gadget pane stack status ;

: usable-words ( -- words )
    use get hash-concat hash-values ;

: word-completion ( pane -- )
    usable-words swap pane-input set-possibilities ;

: show-stack ( seq pack -- )
    dup clear-gadget [
        dup empty? [
            "Empty stack" write drop
        ] [
            "Stack top: " write reverse-slice
            [ [ unparse-short ] keep simple-object bl ] each bl
        ] if
    ] with-stream* ;

: ui-listener-hook ( listener -- )
    [
        >r datastack-hook get call r>
        listener-gadget-stack show-stack
    ] keep
    listener-gadget-pane word-completion ;

: listener-thread ( listener -- )
    dup listener-gadget-pane [
        [ ui-listener-hook ] curry listener-hook set
        print-banner listener
    ] with-stream* ;

: <status-bar> ( -- gadget ) "" <label> dup highlight-theme ;

: <stack-bar> ( -- gadget ) <shelf> dup highlight-theme ;

C: listener-gadget ( -- gadget )
    dup delegate>frame
    <input-pane> dup pick set-listener-gadget-pane
    <scroller> over @center frame-add
    <status-bar> dup pick set-listener-gadget-status
    over @bottom frame-add
    <stack-bar> dup pick set-listener-gadget-stack
    over @top frame-add ;

: listener-window ( -- )
    <listener-gadget> dup dup listener-gadget-status
    { 600 700 0 } "Listener" in-window
    [ >r clear r> listener-thread ] in-thread
    listener-gadget-pane request-focus ;
