! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays gadgets gadgets-borders gadgets-buttons
gadgets-labels gadgets-scrolling gadgets-paragraphs
gadgets-traverse gadgets-theme generic hashtables io kernel
namespaces sequences styles strings quotations math opengl ;
IN: gadgets-panes

TUPLE: pane output current prototype scrolls?
selection-color caret mark selecting? ;

: clear-selection ( pane -- )
    f over set-pane-caret
    f swap set-pane-mark ;

: add-output 2dup set-pane-output add-gadget ;

: add-current 2dup set-pane-current add-gadget ;

: prepare-line ( pane -- )
    dup clear-selection
    dup pane-prototype clone swap add-current ;

: pane-caret&mark ( pane -- caret mark )
    dup pane-caret swap pane-mark ;

: selected-children ( pane -- seq )
    [ pane-caret&mark 2dup <=> 0 > [ swap ] when ] keep
    gadget-subtree ;

M: pane gadget-selection? pane-caret&mark = not ;

M: pane gadget-selection
    selected-children gadget-text ;

: pane-clear ( pane -- )
    dup clear-selection
    dup pane-output clear-incremental
    pane-current clear-gadget ;

C: pane ( -- pane )
    <pile> over set-delegate
    <shelf> over set-pane-prototype
    <pile> <incremental> over add-output
    dup prepare-line
    dup pane-theme ;

GENERIC: draw-selection ( loc obj -- )

: if-fits ( rect quot -- )
    >r clip get over intersects? r> [ drop ] if ; inline

M: gadget draw-selection ( loc gadget -- )
    swap offset-rect [ rect-extent gl-fill-rect ] if-fits ;

M: node draw-selection ( loc node -- )
    2dup node-value swap offset-rect [
        drop 2dup
        [ node-value rect-loc v+ ] keep
        node-children [ draw-selection ] each-with
    ] if-fits 2drop ;

M: pane draw-gadget*
    dup gadget-selection? [
        dup pane-selection-color gl-color
        origin get over rect-loc v- swap selected-children
        [ draw-selection ] each-with
    ] [
        drop
    ] if ;

: scroll-pane ( pane -- )
    dup pane-scrolls? [ scroll>bottom ] [ drop ] if ;

TUPLE: pane-stream pane ;

: smash-line ( current -- gadget )
    dup gadget-children {
        { [ dup empty? ] [ 2drop "" <label> ] }
        { [ dup length 1 = ] [ nip first ] }
        { [ t ] [ drop ] }
    } cond ;

: pane-nl ( pane -- )
    dup pane-current dup unparent smash-line
    over pane-output add-incremental
    prepare-line ;

: pane-write ( pane seq -- )
    [ dup pane-nl ]
    [ over pane-current stream-write ]
    interleave drop ;

: pane-format ( style pane seq -- )
    [ dup pane-nl ]
    [ pick pick pane-current stream-format ]
    interleave 2drop ;

GENERIC: write-gadget ( gadget stream -- )

M: pane-stream write-gadget
    pane-stream-pane pane-current add-gadget ;

M: duplex-stream write-gadget
    duplex-stream-out write-gadget ;

: print-gadget ( gadget stream -- )
    tuck write-gadget stream-nl ;

: gadget. ( gadget -- )
    stdio get print-gadget ;

: ?nl ( stream -- )
    dup pane-stream-pane pane-current gadget-children empty?
    [ dup stream-nl ] unless drop ;

: with-pane ( pane quot -- )
    over scroll>top
    over pane-clear >r <pane-stream> r>
    over >r with-stream r> ?nl ; inline

: <scrolling-pane> ( -- pane )
    <pane> t over set-pane-scrolls? ;

: <pane-control> ( model quot -- pane )
    [ with-pane ] curry <pane> swap <control> ;

: caret>mark ( pane -- )
    dup pane-caret over set-pane-mark relayout-1 ;

: start-selection ( pane -- )
    dup gadget-parent hand-rel over pick-up dup [
        dup scroll>gadget
        dupd gadget-path over set-pane-caret relayout-1
    ] [
        2drop
    ] if ;

: extend-selection ( pane -- )
    dup pane-selecting? [ start-selection ] [ drop ] if ;

: finish-selection ( pane -- )
    f over set-pane-selecting?
    dup gadget-selection? [
        dup request-focus
    ] [
        com-copy-selection
    ] if ;

: position-caret ( pane -- )
    t over set-pane-selecting?
    dup start-selection
    dup caret>mark
    relayout-1 ;

pane H{
    { T{ button-down f { S+ } 1 } [ dup request-focus start-selection ] }
    { T{ button-up } [ finish-selection ] }
    { T{ button-down } [ position-caret ] }
    { T{ drag } [ extend-selection ] }
    { T{ copy-action } [ com-copy ] }
} set-gestures
