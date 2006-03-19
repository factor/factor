! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets-listener
USING: arrays compiler gadgets gadgets-editors gadgets-labels
gadgets-layouts gadgets-panes gadgets-scrolling
gadgets-splitters gadgets-theme generic hashtables
inference inspector io jedit kernel listener lists math
namespaces parser prettyprint sequences shells threads words
help ;

SYMBOL: stack-bar

: in-browser ( quot -- )
    make-pane <scroller> "Browser" simple-window ; inline

: in-listener ( quot -- )
    pane get pane-call ; inline

: usable-words ( -- words )
    use get hash-concat hash-values ;

: word-completion ( -- )
    usable-words [ word-name ] map
    pane get pane-input set-possibilities ;

: show-stack ( seq pack -- )
    dup clear-gadget [
        dup empty? [
            "Empty stack" write drop
        ] [
            "Stack top: " write reverse-slice
            [ [ unparse-short ] keep simple-object bl ] each bl
        ] if
    ] with-stream* ;

: ui-listener-hook ( -- )
    datastack-hook get call stack-bar get show-stack
    word-completion ;

: help-button
    "Please read the " write { "handbook" } $link "." print ;

: listener-thread
    pane get [
        [ ui-listener-hook ] listener-hook set
        help-button
        listener
    ] with-stream* ;

: <status-bar> ( -- gadget ) "" <label> dup status-theme ;

: <bottom-bar> ( -- gadget status )
    <status-bar> [
        <shelf> dup stack-bar set-global
        2array make-pile 1 over set-pack-fill
    ] keep ;

: <scroller> ( -- gadget )
    <input-pane> dup pane set-global <scroller> ;

: <listener> ( -- gadget status )
    <frame> dup solid-interior
    <input-pane> dup pane set-global <scroller>
    over @center frame-add
    <bottom-bar> >r over @bottom frame-add r> ;

: listener-window ( -- )
    <listener> { 600 700 0 } "Listener" in-window
    [ clear listener-thread ] in-thread
    pane get request-focus ;
