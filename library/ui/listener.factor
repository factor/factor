! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-listener
USING: arrays gadgets gadgets-editors gadgets-labels
gadgets-layouts gadgets-panes gadgets-scrolling
gadgets-splitters gadgets-theme generic hashtables io jedit
kernel listener math namespaces parser prettyprint
sequences styles threads words ;

TUPLE: listener-gadget pane stack ;

: usable-words ( -- words )
    use get hash-concat hash-values ;

: word-completion ( pane -- )
    usable-words swap pane-input set-possibilities ;

: show-stack ( seq pack -- )
    dup clear-gadget [
        dup empty? [
            "Empty stack" write drop
        ] [
            "Stack top: " write <reversed>
            [ [ unparse-short ] keep simple-object bl ] each bl
        ] if
    ] with-stream* ;

: ui-listener-hook ( listener -- )
    [
        >r datastack-hook get call r>
        listener-gadget-stack show-stack
    ] keep
    listener-gadget-pane word-completion ;

: ui-error-hook ( error -- )
    terpri H{ { font-style bold } } [
        "Debug this error" swap simple-object terpri
    ] with-style ;

: listener-thread ( listener -- )
    dup listener-gadget-pane [
        [ ui-listener-hook ] curry listener-hook set
        [ ui-error-hook ] error-hook set
        print-banner listener
    ] with-stream* ;

: <stack-bar> ( -- gadget ) <shelf> dup highlight-theme ;

: start-listener ( listener -- )
    [ >r clear r> listener-thread ] in-thread ;

C: listener-gadget ( -- gadget )
    dup delegate>frame
    <input-pane> dup pick set-listener-gadget-pane
    <scroller> over @center frame-add
    <stack-bar> dup pick set-listener-gadget-stack
    over @top frame-add
    dup start-listener ;

M: listener-gadget pref-dim* drop { 600 600 0 } ;

M: listener-gadget focusable-child* ( listener -- gadget )
    listener-gadget-pane ;

: listener-window ( -- )
    <listener-gadget> "Listener" open-window ;
