! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-panes
USING: arrays gadgets gadgets-buttons gadgets-controls
gadgets-frames gadgets-grids gadgets-labels gadgets-scrolling
gadgets-theme generic hashtables io kernel math namespaces
sequences strings ;

TUPLE: pane output active current prototype ;

: add-output 2dup set-pane-output add-gadget ;

: init-line ( pane -- )
    dup pane-prototype clone swap set-pane-current ;

: prepare-line ( pane -- )
    dup init-line dup pane-active unparent
    [ pane-current 1array make-shelf ] keep
    2dup set-pane-active add-gadget ;

: pane-clear ( pane -- )
    dup pane-output clear-incremental pane-current clear-gadget ;

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

: write-gadget ( gadget pane -- )
    #! Print a gadget to the given pane.
    pane-current add-gadget ;

: print-gadget ( gadget pane -- )
    tuck write-gadget stream-terpri ;

: gadget. ( gadget -- )
    #! Print a gadget to the current pane.
    stdio get print-gadget ;

! Panes are streams.
M: pane stream-flush ( pane -- ) drop ;

: scroll-pane ( pane -- )
    #! Only input panes scroll.
    drop ;
    ! dup pane-input [ dup pane-active scroll>gadget ] when drop ;

M: pane stream-terpri ( pane -- )
    dup pane-current prepare-print
    over pane-output add-incremental
    dup prepare-line
    scroll-pane ;

M: pane stream-write1 ( char pane -- )
    [ pane-current stream-write1 ] keep scroll-pane ;

M: pane stream-write ( string pane -- )
    [ swap "\n" split pane-write ] keep scroll-pane ;

M: pane stream-format ( string style pane -- )
    [ rot "\n" split pane-format ] keep scroll-pane ;

M: pane stream-close ( pane -- ) drop ;

M: pane with-stream-style ( quot style pane -- )
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

: <pane-control> ( model quot -- pane )
    [ with-pane ] curry <pane> swap <control> ;
