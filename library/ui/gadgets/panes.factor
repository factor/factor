! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-panes
USING: gadgets gadgets-buttons gadgets-labels
gadgets-scrolling gadgets-theme generic hashtables io kernel
namespaces sequences ;

TUPLE: pane output current prototype scrolls? ;

: add-output 2dup set-pane-output add-gadget ;

: add-current 2dup set-pane-current add-gadget ;

: prepare-line ( pane -- )
    dup pane-prototype clone swap add-current ;

: pane-clear ( pane -- )
    dup
    pane-output clear-incremental
    pane-current clear-gadget ;

C: pane ( -- pane )
    <pile> over set-delegate
    <shelf> over set-pane-prototype
    <pile> <incremental> over add-output
    dup prepare-line ;

: prepare-print ( current -- gadget )
    #! Optimization: if line has 1 child, add the child.
    dup gadget-children {
        { [ dup empty? ] [ 2drop "" <label> ] }
        { [ dup length 1 = ] [ nip first ] }
        { [ t ] [ drop ] }
    } cond ;

: pane-write ( pane seq -- )
    [ over pane-current stream-write ]
    [ dup stream-terpri ] interleave drop ;

: pane-format ( style pane seq -- )
    [ pick pick pane-current stream-format ]
    [ dup stream-terpri ] interleave 2drop ;

GENERIC: write-gadget ( gadget stream -- )

M: pane write-gadget
    #! Print a gadget to the given pane.
    pane-current add-gadget ;

M: duplex-stream write-gadget
    duplex-stream-out write-gadget ;

: print-gadget ( gadget pane -- )
    tuck write-gadget stream-terpri ;

: gadget. ( gadget -- )
    #! Print a gadget to the current pane.
    stdio get print-gadget ;

! Panes are streams.
M: pane stream-flush drop ;

: scroll-pane ( pane -- )
    dup pane-scrolls? [ scroll>bottom ] [ drop ] if ;

M: pane stream-terpri
    dup pane-current dup unparent prepare-print
    over pane-output add-incremental
    dup prepare-line
    scroll-pane ;

M: pane stream-write1
    [ pane-current stream-write1 ] keep scroll-pane ;

M: pane stream-write
    [ swap "\n" split pane-write ] keep scroll-pane ;

M: pane stream-format
    [ rot "\n" split pane-format ] keep scroll-pane ;

M: pane stream-close drop ;

M: pane with-stream-style
    (with-stream-style) ;

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

: <scrolling-pane> ( -- pane )
    <pane> t over set-pane-scrolls? ;

: <pane-control> ( model quot -- pane )
    [ with-pane ] curry <pane> swap <control> ;
