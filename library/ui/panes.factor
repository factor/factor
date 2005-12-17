! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets-presentations
DEFER: gadget.

IN: gadgets-panes
USING: arrays gadgets gadgets-buttons gadgets-editors
gadgets-labels gadgets-layouts gadgets-scrolling gadgets-theme
generic hashtables io kernel line-editor lists math namespaces
prettyprint sequences strings styles threads ;

! A pane is an area that can display text.

! output: pile
! current: shelf
! input: editor
TUPLE: pane output active current input prototype
continuation scrolls? ;

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

: replace-input ( string pane -- )
    pane-input set-editor-text ;

: <input-button> ( string -- button )
    dup <label> dup editor-theme
    swap [ nip pane get replace-input ] curry
    <roll-button> ;

: print-input ( string pane -- )
    [ <input-button> gadget. ] with-stream* ;

: pane-return ( pane -- )
    dup pane-input dup [
        editor-commit swap 2dup print-input 2dup pane-eval
    ] when 2drop ;

: pane-clear ( pane -- )
    dup pane-output clear-incremental pane-current clear-gadget ;
 
: pane-actions ( line -- )
    H{
        { [ button-down 1 ] [ pane-input [ click-editor ] when* ] }
        { [ "RETURN" ] [ pane-return ] }
        { [ "UP" ] [ pane-input [ [ history-prev ] with-editor ] when* ] }
        { [ "DOWN" ] [ pane-input [ [ history-next ] with-editor ] when* ] }
        { [ "CTRL" "l" ] [ pane get pane-clear ] }
    } add-actions ;

C: pane ( input? scrolls? -- pane )
    #! You can create output-only panes. If the scrolls flag is
    #! set, the pane will scroll to the bottom when input is
    #! added.
    [ set-pane-scrolls? ] keep
    <shelf> over set-pane-prototype
    <pile> over set-delegate
    <pile> <incremental> over add-output
    swap [ "" <editor> over set-pane-input ] when
    dup prepare-line dup pane-actions ;

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

: pane-write ( pane list -- )
    2dup car swap pane-current stream-write cdr dup
    [ over stream-terpri pane-write ] [ 2drop ] if ;

: pane-format ( style pane list -- )
    3dup car -rot pane-current stream-format cdr dup
    [ over stream-terpri pane-format ] [ 3drop ] if ;

! Panes are streams.
M: pane stream-flush ( pane -- ) drop ;

M: pane stream-readln ( pane -- line )
    [ over set-pane-continuation stop ] callcc1 nip ;

: scroll-pane ( pane -- )
    dup pane-scrolls? [ pane-input scroll>caret ] [ drop ] if ;

M: pane stream-write1 ( char pane -- )
    [ pane-current stream-write1 ] keep scroll-pane ;

M: pane stream-write ( string pane -- )
    [ swap "\n" split pane-write ] keep scroll-pane ;

M: pane stream-format ( string style pane -- )
    [ rot "\n" split pane-format ] keep scroll-pane ;

M: pane stream-break ( pane -- ) pane-current stream-break ;

M: pane stream-close ( pane -- ) drop ;

: ?pane-terpri ( pane -- )
    dup pane-current gadget-children empty?
    [ dup stream-terpri ] unless drop ;

: make-pane ( quot -- pane )
    #! Execute the quotation with output to an output-only pane.
    f f <pane> [ swap with-stream ] keep
    dup ?pane-terpri pane-output ; inline

: with-pane ( pane quot -- )
    #! Clear the pane and run the quotation in a scope with
    #! stdio set to the pane.
    >r dup pane-clear r> with-stream* ; inline
