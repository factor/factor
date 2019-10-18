! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: gadgets-workspace gadgets-scrolling gadgets-tiles
gadgets-tracks gadgets-workspace gadgets kernel sequences math
definitions ;
IN: gadgets-browser

TUPLE: browser definitions ;

C: browser ( -- gadget )
    [
        toolbar,
        <pile> { 2 2 } over set-pack-gap
        g-> set-browser-definitions
        <scroller> 1 track,
    ] { 0 1 } build-track ;

: definition-index ( defspec objects -- n )
    gadget-children [ tile-object ] map [ = ] find-with drop ;
    inline

M: browser call-tool* ( defspec browser -- )
    browser-definitions 2dup definition-index
    [
        over nth-gadget swap scroll>rect drop
    ] [
        swap [ see ] <tile> over add-gadget scroll>bottom
    ] if* ;

: clear ( browser -- ) browser-definitions clear-gadget ;

: browser-help "ui-browser" help-window ;

\ browser-help H{ { +nullary+ t } } define-command

browser "toolbar" f {
    { T{ key-down f f "CLEAR" } clear }
    { T{ key-down f f "F1" } browser-help }
} define-command-map
