! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets-listener
USING: arrays gadgets gadgets-editors gadgets-labels
gadgets-layouts gadgets-panes gadgets-scrolling
gadgets-splitters gadgets-theme generic hashtables
io jedit kernel listener lists math
namespaces parser prettyprint sequences threads words ;

TUPLE: listener-gadget pane stack status ;

: in-browser ( quot -- )
    make-pane <scroller> "Browser" simple-window ; inline

: in-listener ( quot -- )
    pane get pane-call ; inline

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

: <status-bar> ( -- gadget ) "" <label> dup status-theme ;

: <stack-bar> ( -- gadget ) <shelf> dup status-theme ;

: <scroller> ( -- gadget )
    <input-pane> dup pane set-global <scroller> ;

C: listener-gadget ( -- gadget )
    <frame> over set-delegate
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
