! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets-presentations
USING: arrays gadgets gadgets-borders gadgets-labels
gadgets-layouts gadgets-outliner gadgets-panes hashtables io
kernel sequences strings styles ;

: init-commands ( style gadget -- gadget )
    presented rot hash [ <command-button> ] when* ;

: style-font ( style -- font )
    [ font swap hash [ "Monospaced" ] unless* ] keep
    [ font-style swap hash [ plain ] unless* ] keep
    font-size swap hash [ 12 ] unless* 3array ;

: <styled-label> ( style text -- label )
    <label> foreground pick hash [ over set-label-color ] when*
    swap style-font over set-label-font ;

: <presentation> ( style text -- presentation )
    gadget pick hash
    [ ] [ >r dup dup r> <styled-label> init-commands ] ?if
    outline rot hash [ <outliner> ] when* ;

UNION: gadget-stream pack paragraph ;

M: gadget-stream stream-write ( string stream -- )
    over empty? [ 2drop ] [ >r <label> r> add-gadget ] if ;

M: gadget-stream stream-write1 ( char stream -- )
    >r ch>string r> stream-write ;

M: gadget-stream stream-format ( string style stream -- )
    pick empty? pick hash-empty? and [
        3drop
    ] [
        >r swap <presentation> r> add-gadget
    ] if ;

M: gadget-stream stream-break ( stream -- )
    <break> swap add-gadget ;

M: gadget-stream stream-close ( stream -- ) drop ;

: paragraph-style ( pane style -- pane )
    border-width over hash [ >r <border> r> ] when
    border-color swap hash
    [ <solid> over set-gadget-boundary ] when* ;

M: pane with-nested-stream ( quot style stream -- )
    >r >r make-pane r> paragraph-style
    r> pane-current add-gadget ;
