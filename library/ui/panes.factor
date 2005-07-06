! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic hashtables io kernel line-editor listener lists
math namespaces prettyprint sequences strings styles threads ;

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

: pane-eval ( line pane -- )
    2dup stream-write "\n" over stream-write
    pop-continuation in-thread drop ;

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

: pane-write-1 ( style text pane -- )
    [ <presentation> ] keep pane-current add-incremental ;

: pane-terpri ( pane -- )
    dup pane-current over pane-output add-incremental
    <line-shelf> over set-pane-current init-active-line ;

: pane-write ( style pane list -- )
    3dup car swap pane-write-1 cdr dup
    [ over pane-terpri pane-write ] [ 3drop ] ifte ;

! Panes are streams.
M: pane stream-flush ( stream -- ) relayout ;

M: pane stream-auto-flush ( stream -- ) stream-flush ;

M: pane stream-readln ( stream -- line )
    [ over set-pane-continuation stop ] callcc1 nip ;

M: pane stream-write-attr ( string style stream -- )
    [ rot "\n" split pane-write ] keep scroll>bottom ;

M: pane stream-close ( stream -- ) drop ;

: <console> ( -- pane )
    <pane> dup
    [ [ clear  print-banner listener ] in-thread ] with-stream
    <scroller> ;
