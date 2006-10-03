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

TUPLE: workspace ;

TUPLE: tool gadget ;

: find-tool ( class workspace -- index tool )
    gadget-children [ tool-gadget class eq? ] find-with ;

: show-tool ( class workspace -- tool )
    [ find-tool swap ] keep control-model set-model* ;

: select-tool ( workspace class -- ) swap show-tool drop ;

: find-workspace ( -- workspace )
    [ workspace? ] find-window
    [ world-gadget ] [ workspace-window find-workspace ] if* ;

: call-tool ( arg class -- )
    find-workspace show-tool call-tool* ;

: get-tool ( class -- gadget )
    find-workspace find-tool nip tool-gadget ;

: find-messages ( -- gadget ) messages get-tool ;
