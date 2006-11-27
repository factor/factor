! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-messages
DEFER: messages

IN: gadgets-workspace
USING: gadgets gadgets-books gadgets-workspace
generic kernel models scratchpad sequences syntax
gadgets-messages ;

DEFER: workspace-window

GENERIC: call-tool* ( arg tool -- )

GENERIC: tool-scroller ( tool -- scroller )

M: gadget tool-scroller drop f ;

GENERIC: tool-help ( tool -- topic )

M: gadget tool-help drop f ;

TUPLE: workspace book popup ;

: find-workspace [ workspace? ] find-parent ;

TUPLE: tool gadget ;

: find-tool ( class workspace -- index tool )
    workspace-book gadget-children
    [ tool-gadget class eq? ] find-with ;

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
    get-workspace find-tool nip tool-gadget ;

: find-messages ( -- gadget ) messages get-tool ;
