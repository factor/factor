! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: help
DEFER: <tutorial-button>

IN: gadgets-listener
USING: gadgets gadgets-editors gadgets-labels gadgets-layouts
gadgets-panes gadgets-presentations gadgets-scrolling
gadgets-splitters gadgets-theme generic hashtables help
inspector io kernel listener lists math namespaces prettyprint
sdl sequences shells styles threads words ;

SYMBOL: datastack-display
SYMBOL: callstack-display

TUPLE: display title pane ;

: <display-title> ( text -- label )
    <label> dup display-title-theme ;

: add-display-title ( title display -- )
    2dup set-display-title @top frame-add ;

C: display ( -- display )
    dup delegate>frame
    "" <display-title> over add-display-title
    f f <pane> 2dup swap set-display-pane
    <scroller> over @center frame-add ;

: present-stack ( seq title display -- )
    [ display-title set-label-text ] keep
    [ display-title relayout ] keep
    display-pane [ stack. ] with-pane ;

: present-datastack ( -- )
    datastack-hook get call datastack-display get present-stack ;

: present-callstack ( -- )
    callstack-hook get call callstack-display get present-stack ;

: usable-words ( -- words )
    "use" get prune [ words ] map concat ;

: word-completion ( -- )
    usable-words [ word-name ] map
    pane get pane-input set-possibilities ;

: ui-listener-hook ( -- )
    present-datastack present-callstack word-completion ;

: listener-thread
    pane get [
        [ datastack "Data stack:" ] datastack-hook set
        [ callstack "Return stack:" ] callstack-hook set
        [ ui-listener-hook ] listener-hook set
        <tutorial-button> gadget.
        tty
    ] with-stream* ;

: <stack-display> ( -- gadget )
    <display> dup datastack-display set
    <display> dup callstack-display set
    1/2 <x-splitter> ;

: <status-bar> ( -- gadget )
    "" <label> dup status-theme ;

: listener-application ( -- )
    t t <pane> dup pane global set-hash
    <scroller> <stack-display>
    2/3 <y-splitter> set-application
    <status-bar> set-status
    [ clear listener-thread ] in-thread
    pane get request-focus ;
