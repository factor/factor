! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-workspace
USING: gadgets gadgets-books gadgets-workspace gadgets-panes
gadgets-scrolling gadgets-tracks generic kernel models
scratchpad sequences errors syntax help ;

DEFER: workspace-window

GENERIC: call-tool* ( arg tool -- )

GENERIC: tool-scroller ( tool -- scroller )

M: gadget tool-scroller drop f ;

TUPLE: workspace book listener popup ;

: find-workspace [ workspace? ] find-parent ;

TUPLE: tool gadget ;

: find-tool ( class workspace -- index tool )
    workspace-book gadget-children [ class eq? ] find-with ;

: show-tool ( class workspace -- tool )
    [ find-tool swap ] keep workspace-book control-model
    set-model ;

: select-tool ( workspace class -- ) swap show-tool drop ;

: get-workspace* ( quot -- workspace )
    [ dup workspace? [ over call ] [ drop f ] if ] find-window
    [ nip dup raise-window world-gadget ]
    [ workspace-window drop get-workspace* ] if* ; inline

: get-workspace ( -- workspace ) [ drop t ] get-workspace* ;

: call-tool ( arg class -- )
    get-workspace show-tool call-tool* ;

: get-tool ( class -- gadget )
    get-workspace find-tool nip ;

: help-window ( topic -- )
    [ [ help ] H{ } make-pane <scroller> ] keep
    article-title open-window ;

: hide-popup ( workspace -- )
    dup workspace-popup over track-remove
    f over set-workspace-popup
    request-focus ;

: show-popup ( gadget workspace -- )
    dup hide-popup
    2dup set-workspace-popup
    dupd f track-add
    request-focus ;

: show-titled-popup ( workspace gadget title -- )
    [ find-workspace hide-popup ] <closable-gadget>
    swap show-popup ;

: debugger-popup ( error workspace -- )
    swap dup compute-restarts
    [ find-workspace hide-popup ] <debugger>
    "Error" show-titled-popup ;
