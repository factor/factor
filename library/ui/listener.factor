! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: help
DEFER: <tutorial-button>

IN: gadgets-listener
USING: gadgets gadgets-labels gadgets-layouts gadgets-panes
gadgets-presentations gadgets-scrolling gadgets-splitters
generic hashtables help io kernel listener lists math namespaces
prettyprint sdl sequences shells styles threads words ;

SYMBOL: datastack-display
SYMBOL: callstack-display

TUPLE: display title pane ;

: display-title-theme
    dup @{ 216 232 255 }@ background set-paint-prop
    << solid f >> interior set-paint-prop ;

: <display-title> ( text -- label )
    <label> dup display-title-theme ;

: add-display-title ( title display -- )
    2dup set-display-title add-top ;

C: display ( -- display )
    <frame> over set-delegate
    "" <display-title> over add-display-title
    f f <pane> 2dup swap set-display-pane
    <scroller> over add-center ;

: present-stack ( seq title display -- )
    [ display-title set-label-text ] keep
    [ display-title relayout ] keep
    display-pane [ stack. ] with-pane ;

: ui-listener-hook ( -- )
    datastack-hook get call datastack-display get present-stack
    callstack-hook get call callstack-display get present-stack ;

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

: listener-application ( -- )
    t t <pane> dup pane global set-hash
    <scroller> <stack-display>
    2/3 <x-splitter> add-layer
    [ clear listener-thread ] in-thread
    pane get request-focus ;
