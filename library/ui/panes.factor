! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: kernel line-editor listener lists namespaces stdio
streams strings threads ;

! A pane is an area that can display text.

! output: pile
! current: label
! input: editor
TUPLE: pane output current input continuation delegate ;

: add-output 2dup set-pane-output add-gadget ;
: add-input 2dup set-pane-input add-gadget ;

: <active-line> ( current input -- line )
    <line-shelf> [ tuck add-gadget add-gadget ] keep ;

: pane-paint ( pane -- )
    [[ "Monospaced" 12 ]] font set-paint-property ;

: pane-return ( pane -- )
    [
        pane-input [
            commit-history line-text get line-clear
        ] with-editor
    ] keep
    2dup stream-write "\n" over stream-write
    pane-continuation call ;
 
: pane-actions ( line -- )
    [
        [[ [ button-down 1 ] [ pane-input click-editor ] ]]
        [[ [ "RETURN" ] [ pane-return ] ]]
        [[ [ "UP" ] [ pane-input [ history-prev ] with-editor ] ]]
        [[ [ "DOWN" ] [ pane-input [ history-next ] with-editor ] ]]
    ] swap add-actions ;

C: pane ( -- pane )
    <line-pile> over set-pane-delegate
    <line-pile> over add-output
    "" <label> dup pick set-pane-current >r
    "" <editor> dup pick set-pane-input r>
    <active-line> over add-gadget
    dup pane-paint
    dup pane-actions ;

: add-line ( text pane -- )
    >r <label> r> pane-output add-gadget ;

: pane-write-1 ( text pane -- )
    pane-current [ label-text swap cat2 ] keep set-label-text ;

: pane-terpri ( pane -- )
    dup pane-current dup label-text rot add-line
    "" over set-label-text relayout ;

: pane-write ( pane list -- )
    2dup car swap pane-write-1
    cdr dup [
        over pane-terpri pane-write
    ] [
        2drop
    ] ifte ;

! Panes are streams.
M: pane stream-flush ( stream -- ) relayout ;
M: pane stream-auto-flush ( stream -- ) relayout ;

M: pane stream-readln ( stream -- line )
    [ swap set-pane-continuation (yield) ] callcc1 nip ;

M: pane stream-write-attr ( string style stream -- )
    nip swap "\n" split pane-write ;

M: pane stream-close ( stream -- ) drop ;

: <console-pane> ( -- pane )
    <pane> dup [
        [ print-banner listener ] in-thread
    ] with-stream ;
