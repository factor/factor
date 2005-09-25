! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets-presentations
DEFER: <presentation>

IN: gadgets-panes
USING: arrays gadgets gadgets-editors gadgets-labels
gadgets-layouts gadgets-scrolling generic hashtables io kernel
line-editor lists math namespaces prettyprint sequences strings
styles threads ;

! A pane is an area that can display text.

! output: pile
! current: shelf
! input: editor
TUPLE: pane output active current input continuation scrolls? ;

: add-output 2dup set-pane-output add-gadget ;

: <active-line> ( current input -- line )
    [ 2array ] [ 1array ] if* <shelf> [ add-gadgets ] keep ;

: init-active-line ( pane -- )
    dup pane-active unparent
    [ dup pane-current swap pane-input <active-line> ] keep
    2dup set-pane-active add-gadget ;

: pop-continuation ( pane -- quot )
    dup pane-continuation f rot set-pane-continuation ;

: pane-eval ( string pane -- )
    pop-continuation dup
    [ [ continue-with ] in-thread ] when 2drop ;

SYMBOL: structured-input

: elements. ( quot -- )
    [
        2 nesting-limit set
        5 length-limit set
        <block pprint-elements block> newline
    ] with-pprint ;

: pane-call ( quot pane -- )
    2dup [ elements. ] with-stream*
    >r structured-input global set-hash
    "\"structured-input\" \"gadgets-panes\" lookup global hash call"
    r> pane-eval ;

: editor-commit ( editor -- line )
    #! Add current line to the history, and clear the editor.
    [ commit-history line-text get line-clear ] with-editor ;

: pane-return ( pane -- )
    dup pane-input dup [
        editor-commit swap 2dup stream-print 2dup pane-eval
    ] when 2drop ;

: pane-clear ( pane -- )
    dup pane-output clear-incremental pane-current clear-gadget ;
 
: pane-actions ( line -- )
    [
        [[ [ button-down 1 ] [ pane-input [ click-editor ] when* ] ]]
        [[ [ "RETURN" ] [ pane-return ] ]]
        [[ [ "UP" ] [ pane-input [ [ history-prev ] with-editor ] when* ] ]]
        [[ [ "DOWN" ] [ pane-input [ [ history-next ] with-editor ] when* ] ]]
        [[ [ "CTRL" "l" ] [ pane get pane-clear ] ]]
    ] swap add-actions ;

C: pane ( input? scrolls? -- pane )
    #! You can create output-only panes. If the scrolls flag is
    #! set, the pane will scroll to the bottom when input is
    #! added.
    [ set-pane-scrolls? ] keep
    <pile> over set-delegate
    <pile> <incremental> over add-output
    <shelf> over set-pane-current
    swap [ "" <editor> over set-pane-input ] when
    dup init-active-line
    dup pane-actions ;

M: pane focusable-child* ( pane -- editor )
    pane-input [ t ] unless* ;

: pane-write-1 ( style text pane -- )
    pick not pick empty? and [
        3drop
    ] [
        >r <presentation> r> pane-current add-gadget
    ] if ;

: prepare-print ( current -- gadget )
    #! Optimization: if line has 1 child, add the child.
    dup gadget-children @{
        @{ [ dup empty? ] [ 2drop "" <label> ] }@
        @{ [ dup length 1 = ] [ nip first ] }@
        @{ [ t ] [ drop ] }@
    }@ cond ;

: pane-print-1 ( current pane -- )
    >r prepare-print r> pane-output add-incremental ;

: pane-terpri ( pane -- )
    dup pane-current over pane-print-1
    <shelf> over set-pane-current init-active-line ;

: pane-write ( style pane list -- )
    3dup car swap pane-write-1 cdr dup
    [ over pane-terpri pane-write ] [ 3drop ] if ;

! Panes are streams.
M: pane stream-flush ( pane -- ) drop ;

M: pane stream-finish ( pane -- ) drop ;

M: pane stream-readln ( pane -- line )
    [ over set-pane-continuation stop ] callcc1 nip ;

: ?scroll>bottom ( pane -- )
    dup pane-scrolls? [ dup scroll>bottom ] when drop ;

M: pane stream-write1 ( char pane -- )
    [ >r ch>string <label> r> pane-current add-gadget ] keep
    ?scroll>bottom ;

M: pane stream-format ( string style pane -- )
    [ rot "\n" split pane-write ] keep ?scroll>bottom ;

M: pane stream-close ( pane -- ) drop ;

: make-pane ( quot -- pane )
    #! Execute the quotation with output to an output-only pane.
    f f <pane> world-theme over set-gadget-paint
    [ swap with-stream ] keep ; inline

: with-pane ( pane quot -- )
    #! Clear the pane and run the quotation in a scope with
    #! stdio set to the pane.
    >r dup pane-clear r> with-stream* ; inline
