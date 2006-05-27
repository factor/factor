! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets-panes
USING: arrays gadgets gadgets-buttons gadgets-editors
gadgets-labels gadgets-layouts gadgets-scrolling gadgets-theme
generic hashtables io kernel line-editor math namespaces
prettyprint sequences strings styles threads ;

! A pane is an area that can display text.

! output: pile
! current: shelf
! input: editor
TUPLE: pane output active current input prototype continuation ;

: add-output 2dup set-pane-output add-gadget ;

: <active-line> ( current input -- line )
    [ 2array ] [ 1array ] if* make-shelf ;

: init-line ( pane -- )
    dup pane-prototype clone swap set-pane-current ;

: prepare-line ( pane -- )
    dup init-line dup pane-active unparent
    [ dup pane-current swap pane-input <active-line> ] keep
    2dup set-pane-active add-gadget ;

: pop-continuation ( pane -- quot )
    dup pane-continuation f rot set-pane-continuation ;

: pane-eval ( string pane -- )
    pop-continuation dup [
        [ continue-with ] in-thread
    ] when 2drop ;

SYMBOL: structured-input

: pane-call ( quot pane -- )
    dup [ "Command: " write over short. ] with-stream*
    >r structured-input set-global
    "\"structured-input\" \"gadgets-panes\" lookup get-global call"
    r> pane-eval ;

: replace-input ( string pane -- ) pane-input set-editor-text ;

: print-input ( string pane -- )
    [
        dup [
            <input> presented set
            bold font-style set
        ] make-hash format terpri
    ] with-stream* ;

: pane-commit ( pane -- )
    dup pane-input commit-editor-text
    swap 2dup print-input pane-eval ;

: pane-clear ( pane -- )
    dup pane-output clear-incremental pane-current clear-gadget ;

C: pane ( -- pane )
    <pile> over set-delegate
    <shelf> over set-pane-prototype
    <pile> <incremental> over add-output
    dup prepare-line ;

M: pane gadget-gestures
    pane-input [
        H{
            { T{ button-down } [ pane-input click-editor ] }
            { T{ key-down f f "RETURN" } [ pane-commit ] }
            { T{ key-down f f "UP" } [ pane-input [ history-prev ] with-editor ] }
            { T{ key-down f f "DOWN" } [ pane-input [ history-next ] with-editor ] }
            { T{ key-down f { C+ } "l" } [ pane-clear ] }
        }
    ] [
        H{ }
    ] if ;

: <input-pane> ( -- pane )
    <pane> "" <editor> over set-pane-input ;

M: pane focusable-child* ( pane -- editor )
    pane-input [ t ] unless* ;

: prepare-print ( current -- gadget )
    #! Optimization: if line has 1 child, add the child.
    dup gadget-children {
        { [ dup empty? ] [ 2drop "" <label> ] }
        { [ dup length 1 = ] [ nip first ] }
        { [ t ] [ drop ] }
    } cond ;

M: pane stream-terpri ( pane -- )
    dup pane-current prepare-print
    over pane-output add-incremental
    prepare-line ;

: pane-write ( pane seq -- )
    [ over pane-current stream-write ]
    [ dup stream-terpri ] interleave drop ;

: pane-format ( style pane seq -- )
    [ pick pick pane-current stream-format ]
    [ dup stream-terpri ] interleave 2drop ;

: write-gadget ( gadget pane -- )
    #! Print a gadget to the given pane.
    pane-current add-gadget ;

: gadget. ( gadget -- )
    #! Print a gadget to the current pane.
    stdio get write-gadget terpri ;

! Panes are streams.
M: pane stream-flush ( pane -- ) drop ;

M: pane stream-readln ( pane -- line )
    [ over set-pane-continuation stop ] callcc1 nip ;

: scroll-pane ( pane -- ) pane-input [ scroll>caret ] when* ;

M: pane stream-write1 ( char pane -- )
    [ pane-current stream-write1 ] keep scroll-pane ;

M: pane stream-write ( string pane -- )
    [ swap "\n" split pane-write ] keep scroll-pane ;

M: pane stream-format ( string style pane -- )
    [ rot "\n" split pane-format ] keep scroll-pane ;

M: pane stream-close ( pane -- ) drop ;

: ?terpri
    dup pane-current gadget-children empty?
    [ dup stream-terpri ] unless drop ;

: with-pane ( pane quot -- )
    #! Clear the pane and run the quotation in a scope with
    #! stdio set to the pane.
    over pane-clear over >r with-stream* r> ?terpri ; inline

: make-pane ( quot -- pane )
    #! Execute the quotation with output to an output-only pane.
    <pane> [ swap with-pane ] keep ; inline
