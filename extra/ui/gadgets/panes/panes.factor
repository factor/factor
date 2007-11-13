! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays ui.gadgets ui.gadgets.borders ui.gadgets.buttons
ui.gadgets.labels ui.gadgets.scrollers
ui.gadgets.paragraphs ui.gadgets.incremental ui.gadgets.packs
ui.gadgets.theme ui.clipboards ui.gestures ui.traverse ui.render
hashtables io kernel namespaces sequences io.styles strings
quotations math opengl combinators math.vectors
io.streams.duplex sorting splitting io.streams.nested assocs
ui.gadgets.presentations ui.gadgets.slots ui.gadgets.grids
ui.gadgets.grid-lines tuples ;
IN: ui.gadgets.panes

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
    [ pane-caret&mark sort-pair ] keep gadget-subtree ;

M: pane gadget-selection? pane-caret&mark and ;

M: pane gadget-selection
    selected-children gadget-text ;

: pane-clear ( pane -- )
    dup clear-selection
    dup pane-output clear-incremental
    pane-current clear-gadget ;

: pane-theme ( editor -- )
    selection-color swap set-pane-selection-color ;

: <pane> ( -- pane )
    pane construct-empty
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
        node-children [ draw-selection ] curry* each
    ] if-fits 2drop ;

M: pane draw-gadget*
    dup gadget-selection? [
        dup pane-selection-color gl-color
        origin get over rect-loc v- swap selected-children
        [ draw-selection ] curry* each
    ] [
        drop
    ] if ;

: scroll-pane ( pane -- )
    dup pane-scrolls? [ scroll>bottom ] [ drop ] if ;

TUPLE: pane-stream pane ;

C: <pane-stream> pane-stream

: smash-line ( current -- gadget )
    dup gadget-children {
        { [ dup empty? ] [ 2drop "" <label> ] }
        { [ dup length 1 = ] [ nip first ] }
        { [ t ] [ drop ] }
    } cond ;

: smash-pane ( pane -- gadget ) pane-output smash-line ;

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
    over >r with-stream* r> ?nl ; inline

: make-pane ( quot -- gadget )
    <pane> [ swap with-pane ] keep smash-pane ; inline

: <scrolling-pane> ( -- pane )
    <pane> t over set-pane-scrolls? ;

TUPLE: pane-control quot ;

M: pane-control model-changed
    dup control-value swap dup pane-control-quot with-pane ;

: <pane-control> ( model quot -- pane )
    >r <pane> pane-control construct-control r>
    over set-pane-control-quot ;

: do-pane-stream ( pane-stream quot -- )
    >r pane-stream-pane r> keep scroll-pane ; inline

M: pane-stream stream-nl
    [ pane-nl ] do-pane-stream ;

M: pane-stream stream-write1
    [ pane-current stream-write1 ] do-pane-stream ;

M: pane-stream stream-write
    [ swap string-lines pane-write ] do-pane-stream ;

M: pane-stream stream-format
    [ rot string-lines pane-format ] do-pane-stream ;

M: pane-stream stream-close drop ;

M: pane-stream stream-flush drop ;

M: pane-stream make-span-stream
    <style-stream> <ignore-close-stream> ;

! Character styles

: apply-style ( style gadget key quot -- style gadget )
    >r pick at r> when* ; inline

: apply-foreground-style ( style gadget -- style gadget )
    foreground [ over set-label-color ] apply-style ;

: apply-background-style ( style gadget -- style gadget )
    background [ dupd solid-interior ] apply-style ;

: specified-font ( style -- font )
    [ font swap at "monospace" or ] keep
    [ font-style swap at plain or ] keep
    font-size swap at 12 or 3array ;

: apply-font-style ( style gadget -- style gadget )
    over specified-font over set-label-font ;

: apply-presentation-style ( style gadget -- style gadget )
    presented [ <presentation> ] apply-style ;

: <styled-label> ( style text -- gadget )
    <label>
    apply-foreground-style
    apply-background-style
    apply-font-style
    apply-presentation-style
    nip ;

! Paragraph styles

: apply-wrap-style ( style pane -- style pane )
    wrap-margin [
        2dup <paragraph> swap set-pane-prototype
        <paragraph> over set-pane-current
    ] apply-style ;

: apply-border-color-style ( style gadget -- style gadget )
    border-color [ dupd solid-boundary ] apply-style ;

: apply-page-color-style ( style gadget -- style gadget )
    page-color [ dupd solid-interior ] apply-style ;

: apply-path-style ( style gadget -- style gadget )
    presented-path [ <editable-slot> ] apply-style ;

: apply-border-width-style ( style gadget -- style gadget )
    border-width [ <border> ] apply-style ;

: apply-printer-style ( style gadget -- style gadget )
    presented-printer [
        [ make-pane ] curry over set-editable-slot-printer
    ] apply-style ;

: style-pane ( style pane -- pane )
    apply-border-width-style
    apply-border-color-style
    apply-page-color-style
    apply-presentation-style
    apply-path-style
    apply-printer-style
    nip ;

TUPLE: nested-pane-stream style parent ;

: <nested-pane-stream> ( style parent -- stream )
    >r <pane> apply-wrap-style <pane-stream> r> {
        set-nested-pane-stream-style
        set-delegate
        set-nested-pane-stream-parent
    } nested-pane-stream construct ;

: unnest-pane-stream ( stream -- child parent )
    dup ?nl
    dup nested-pane-stream-style
    over pane-stream-pane smash-pane style-pane
    swap nested-pane-stream-parent ;

TUPLE: pane-block-stream ;

M: pane-block-stream stream-close
    unnest-pane-stream write-gadget ;

M: pane-stream make-block-stream
    <nested-pane-stream> pane-block-stream construct-delegate ;

! Tables
: apply-table-gap-style ( style grid -- style grid )
    table-gap [ over set-grid-gap ] apply-style ;

: apply-table-border-style ( style grid -- style grid )
    table-border [ <grid-lines> over set-gadget-boundary ]
    apply-style ;

: styled-grid ( style grid -- grid )
    <grid>
    f over set-grid-fill?
    apply-table-gap-style
    apply-table-border-style
    nip ;

TUPLE: pane-cell-stream ;

M: pane-cell-stream stream-close ?nl ;

M: pane-stream make-cell-stream
    <nested-pane-stream> pane-cell-stream construct-delegate ;

M: pane-stream stream-write-table
    >r
    swap [ [ pane-stream-pane smash-pane ] map ] map
    styled-grid
    r> print-gadget ;

! Stream utilities
M: pack stream-close drop ;

M: paragraph stream-close drop ;

: gadget-write ( string gadget -- )
    over empty? [
        2drop
    ] [
        >r <label> dup text-theme r> add-gadget
    ] if ;

M: pack stream-write gadget-write ;

: gadget-bl ( style stream -- )
    >r " " <styled-label> <word-break-gadget> r> add-gadget ;

M: paragraph stream-write
    swap " " split
    [ H{ } over gadget-bl ] [ over gadget-write ] interleave
    drop ;

: gadget-write1 ( char gadget -- )
    >r 1string r> stream-write ;

M: pack stream-write1 gadget-write1 ;

M: paragraph stream-write1
    over CHAR: \s =
    [ H{ } swap gadget-bl drop ] [ gadget-write1 ] if ;

: gadget-format ( string style stream -- )
    pick empty?
    [ 3drop ] [ >r swap <styled-label> r> add-gadget ] if ;

M: pack stream-format
    gadget-format ;

M: paragraph stream-format
    presented pick at [
        gadget-format
    ] [
        rot " " split
        [ 2dup gadget-bl ]
        [ pick pick gadget-format ] interleave
        2drop
    ] if ;

: caret>mark ( pane -- )
    dup pane-caret over set-pane-mark relayout-1 ;

GENERIC: sloppy-pick-up* ( loc gadget -- n )

M: pack sloppy-pick-up*
    dup gadget-orientation
    swap gadget-children
    (fast-children-on) ;

M: gadget sloppy-pick-up*
    gadget-children [ inside? ] curry* find-last drop ;

M: f sloppy-pick-up*
    2drop f ;

: wet-and-sloppy ( loc gadget n -- newloc newgadget )
    swap nth-gadget [ rect-loc v- ] keep ;

: sloppy-pick-up ( loc gadget -- path )
    2dup sloppy-pick-up* dup
    [ [ wet-and-sloppy sloppy-pick-up ] keep add* ]
    [ 3drop { } ]
    if ;

: move-caret ( pane -- )
    dup hand-rel
    over sloppy-pick-up
    over set-pane-caret
    relayout-1 ;

: begin-selection ( pane -- )
    dup move-caret f swap set-pane-mark ;

: extend-selection ( pane -- )
    hand-moved? [
        dup pane-selecting? [
            dup move-caret
        ] [
            dup hand-clicked get child? [
                t over set-pane-selecting?
                dup hand-clicked set-global
                dup move-caret
                dup caret>mark
            ] when
        ] if
        dup dup pane-caret gadget-at-path scroll>gadget
    ] when drop ;

: end-selection ( pane -- )
    f over set-pane-selecting?
    hand-moved? [
        dup com-copy-selection
        request-focus
    ] [
        relayout-1
    ] if ;

: select-to-caret ( pane -- )
    dup pane-mark [ dup caret>mark ] unless
    dup move-caret
    dup request-focus
    com-copy-selection ;

pane H{
    { T{ button-down } [ begin-selection ] }
    { T{ button-down f { S+ } 1 } [ select-to-caret ] }
    { T{ button-up f { S+ } 1 } [ drop ] }
    { T{ button-up } [ end-selection ] }
    { T{ drag } [ extend-selection ] }
    { T{ copy-action } [ com-copy ] }
} set-gestures
