! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic hashtables io kernel line-editor listener lists
math namespaces prettyprint sequences strings styles threads ;

DEFER: <presentation>

! A pane is an area that can display text.

! output: pile
! current: shelf
! input: editor
TUPLE: pane output active current input continuation ;

: add-output 2dup set-pane-output add-gadget ;

: add-input 2dup set-pane-input add-gadget ;

: <active-line> ( input current -- line )
    <line-shelf> [ add-gadget ] keep [ add-gadget ] keep ;

: init-active-line ( pane -- )
    dup pane-active unparent
    [ dup pane-input swap pane-current <active-line> ] keep
    2dup set-pane-active add-gadget ;

: pane-paint ( pane -- )
    "Monospaced" font set-paint-prop ;

: pop-continuation ( pane -- quot )
    dup pane-continuation f rot set-pane-continuation ;

: pane-eval ( string pane -- )
    2dup stream-print pop-continuation in-thread drop ;

: pane-call ( quot pane -- )
    [ "(Structured input) " write dup . call ] with-stream* ;

: pane-return ( pane -- )
    [
        pane-input
        [ commit-history line-text get line-clear ] with-editor
    ] keep pane-eval ;
 
: pane-actions ( line -- )
    [
        [[ [ button-down 1 ] [ pane-input click-editor ] ]]
        [[ [ "RETURN" ] [ pane-return ] ]]
        [[ [ "UP" ] [ pane-input [ history-prev ] with-editor ] ]]
        [[ [ "DOWN" ] [ pane-input [ history-next ] with-editor ] ]]
    ] swap add-actions ;

C: pane ( -- pane )
    <line-pile> over set-delegate
    <line-pile> <incremental> over add-output
    <line-shelf> over set-pane-current
    "" <editor> over set-pane-input
    dup init-active-line
    dup pane-paint
    dup pane-actions ;

M: pane focusable-child* ( pane -- editor )
    pane-input ;

: pane-clear ( pane -- )
    dup pane-output clear-incremental pane-current clear-gadget ;

: pane-ignore? ( style text pane -- ? )
    #! If we already have stuff in the current pack, and there
    #! is no style information or text to write, ignore it.
    #! Otherwise, we either have a fancy style (like an icon
    #! or gadget being output), or we want the current pack to
    #! have a minimal height so we put the empty label there.
    pane-current gadget-children empty? not
    rot not and swap empty? and ;

: pane-write-1 ( style text pane -- )
    3dup pane-ignore? [
        3drop
    ] [
        >r <presentation> r> pane-current add-gadget
    ] ifte ;

: pane-terpri ( pane -- )
    dup pane-current over pane-output add-incremental
    <line-shelf> over set-pane-current init-active-line ;

: pane-write ( style pane list -- )
    3dup car swap pane-write-1 cdr dup
    [ over pane-terpri pane-write ] [ 3drop ] ifte ;

! Panes are streams.
M: pane stream-flush ( pane -- ) drop ;

M: pane stream-finish ( pane -- ) drop ;

M: pane stream-readln ( pane -- line )
    [ over set-pane-continuation stop ] callcc1 nip ;

M: pane stream-write1 ( char pane -- )
    [ >r ch>string <label> r> pane-current add-gadget ] keep
    scroll>bottom ;

M: pane stream-format ( string style pane -- )
    [ rot "\n" split pane-write ] keep scroll>bottom ;

M: pane stream-close ( pane -- ) drop ;
