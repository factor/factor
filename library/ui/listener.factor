! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: help
DEFER: <tutorial-button>

IN: gadgets-listener
USING: arrays compiler gadgets gadgets-editors gadgets-labels
gadgets-layouts gadgets-panes gadgets-presentations
gadgets-scrolling gadgets-splitters gadgets-theme generic
hashtables inference inspector io jedit kernel listener lists
math namespaces parser prettyprint sequences shells threads
words ;

SYMBOL: stack-bar
SYMBOL: browser-pane

: reveal-in-split ( gadget n -- )
    >r find-splitter dup splitter-split r> - abs 1/16 <
    [ 1/3 over set-splitter-split dup relayout ] when drop ;

: in-browser ( quot -- )
    browser-pane get dup 0 reveal-in-split swap with-pane ; inline

: in-listener ( quot -- )
    pane get dup 1 reveal-in-split pane-call ; inline

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

: listener-thread
    pane get [
        [ ui-listener-hook ] listener-hook set
        <tutorial-button> gadget.
        tty
    ] with-stream* ;

M: label set-message ( string/f status -- )
    set-label-text* ;

: <status-bar> ( -- gadget ) "" <label> dup status-theme ;

: <bottom-bar> ( -- gadget )
    <status-bar> dup world get set-world-status
    <shelf> dup stack-bar set-global
    2array make-pile 1 over set-pack-fill ;

: <browser-scroller> ( -- gadget )
    <pane> dup browser-pane set-global <scroller> ;

: <listener-scroller> ( -- gadget )
    <input-pane> dup pane set-global <scroller> ;

: <listener> ( -- gadget )
    <frame> dup solid-interior
    <browser-scroller> <listener-scroller>
    0 <x-splitter> over @center frame-add
    <bottom-bar> over @bottom frame-add ;

: set-application ( gadget -- )
    world get dup clear-gadget add-gadget ;

: listener-application ( -- )
    <listener> set-application
    [ clear listener-thread ] in-thread
    pane get request-focus ;

"Describe" [ drop t ] [ describe ] \ in-browser define-default-command
"Prettyprint" [ drop t ] [ . ] \ in-listener define-command
"Push on data stack" [ drop t ] [ ] \ in-listener define-command

"See word" [ word? ] [ see ] \ in-browser define-default-command
"Word call hierarchy" [ word? ] [ uses. ] \ in-browser define-command
"Word caller hierarchy" [ word? ] [ usage. ] \ in-browser define-command
"Open in jEdit" [ word? ] [ jedit ] \ call define-command
"Reload original source" [ word? ] [ reload ] \ in-listener define-command
"Annotate with watchpoint" [ compound? ] [ watch ] \ in-listener define-command
"Annotate with breakpoint" [ compound? ] [ break ] \ in-listener define-command
"Annotate with profiling" [ compound? ] [ profile ] \ in-listener define-command
"Compile" [ word? ] [ recompile ] \ in-listener define-command
"Infer stack effect" [ word? ] [ unit infer . ] \ in-listener define-command

"Display gadget" [ [ gadget? ] is? ] [ gadget. ] \ in-listener define-command

"Use as input" [ input? ] [ input-string pane get replace-input ] \ call define-default-command
