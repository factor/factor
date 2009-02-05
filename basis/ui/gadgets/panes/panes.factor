! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays hashtables io kernel namespaces sequences
io.styles strings quotations math opengl combinators memoize
math.vectors sorting splitting assocs classes.tuple models
continuations destructors accessors math.rectangles fry
fonts ui.gadgets ui.gadgets.private ui.gadgets.borders ui.gadgets.buttons
ui.gadgets.labels ui.gadgets.scrollers ui.gadgets.paragraphs
ui.gadgets.incremental ui.gadgets.packs ui.gadgets.theme
ui.gadgets.menus ui.clipboards ui.gestures ui.traverse ui.render
ui.text ui.gadgets.presentations ui.gadgets.grids
ui.gadgets.grid-lines colors ;
IN: ui.gadgets.panes

TUPLE: pane < pack
output current prototype scrolls?
selection-color caret mark selecting? ;

: clear-selection ( pane -- pane )
    f >>caret f >>mark ;

: add-output ( pane current -- pane )
    [ >>output ] [ add-gadget ] bi ;

: add-current ( pane current -- pane )
    [ >>current ] [ add-gadget ] bi ;

: prepare-line ( pane -- )
    clear-selection
    dup prototype>> clone add-current drop ;

: pane-caret&mark ( pane -- caret mark )
    [ caret>> ] [ mark>> ] bi ;

: selected-children ( pane -- seq )
    [ pane-caret&mark sort-pair ] keep gadget-subtree ;

M: pane gadget-selection? pane-caret&mark and ;

M: pane gadget-selection ( pane -- string/f )
    selected-children gadget-text ;

: pane-clear ( pane -- )
    clear-selection
    [ output>> clear-incremental ]
    [ current>> clear-gadget ]
    bi ;

: new-pane ( class -- pane )
    new-gadget
        vertical >>orientation
        <shelf> +baseline+ >>align >>prototype
        <incremental> add-output
        dup prepare-line
        selection-color >>selection-color ;

: <pane> ( -- pane ) pane new-pane ;

GENERIC: draw-selection ( loc obj -- )

: if-fits ( rect quot -- )
    [ clip get over contains-rect? ] dip [ drop ] if ; inline

M: gadget draw-selection ( loc gadget -- )
    swap offset-rect [
        dup loc>> [
            dim>> gl-fill-rect
        ] with-translation
    ] if-fits ;

M: node draw-selection ( loc node -- )
    2dup value>> swap offset-rect [
        drop 2dup
        [ value>> loc>> v+ ] keep
        children>> [ draw-selection ] with each
    ] if-fits 2drop ;

M: pane draw-gadget*
    dup gadget-selection? [
        [ selection-color>> gl-color ]
        [
            [ [ origin get ] dip loc>> v- ] keep selected-children
            [ draw-selection ] with each
        ] bi
    ] [ drop ] if ;

: scroll-pane ( pane -- )
    dup scrolls?>> [ scroll>bottom ] [ drop ] if ;

TUPLE: pane-stream pane ;

C: <pane-stream> pane-stream

: smash-line ( current -- gadget )
    dup children>> {
        { [ dup empty? ] [ 2drop "" <label> ] }
        { [ dup length 1 = ] [ nip first ] }
        [ drop ]
    } cond ;

: smash-pane ( pane -- gadget ) output>> smash-line ;

: pane-nl ( pane -- )
    [
        [ current>> [ unparent ] [ smash-line ] bi ] [ output>> ] bi
        add-incremental
    ]
    [ prepare-line ] bi ;

: pane-write ( seq pane -- )
    [ pane-nl ] [ current>> stream-write ]
    bi-curry interleave ;

: pane-format ( seq style pane -- )
    [ nip pane-nl ] [ current>> stream-format ]
    bi-curry bi-curry interleave ;

GENERIC: write-gadget ( gadget stream -- )

M: pane-stream write-gadget ( gadget pane-stream -- )
    pane>> current>> swap add-gadget drop ;

M: style-stream write-gadget
    stream>> write-gadget ;

: print-gadget ( gadget stream -- )
    [ write-gadget ] [ nip stream-nl ] 2bi ;

: gadget. ( gadget -- )
    output-stream get print-gadget ;

: ?nl ( stream -- )
    dup pane>> current>> children>> empty?
    [ dup stream-nl ] unless drop ;

: with-pane ( pane quot -- )
    over scroll>top
    over pane-clear [ <pane-stream> ] dip
    over [ with-output-stream* ] dip ?nl ; inline

: make-pane ( quot -- gadget )
    <pane> [ swap with-pane ] keep smash-pane ; inline

: <scrolling-pane> ( -- pane ) <pane> t >>scrolls? ;

TUPLE: pane-control < pane quot ;

M: pane-control model-changed ( model pane-control -- )
    [ value>> ] [ dup quot>> ] bi* with-pane ;

: <pane-control> ( model quot -- pane )
    pane-control new-pane
        swap >>quot
        swap >>model ;

: do-pane-stream ( pane-stream quot -- )
    [ pane>> ] dip keep scroll-pane ; inline

M: pane-stream stream-nl
    [ pane-nl ] do-pane-stream ;

M: pane-stream stream-write1
    [ current>> stream-write1 ] do-pane-stream ;

M: pane-stream stream-write
    [ [ string-lines ] dip pane-write ] do-pane-stream ;

M: pane-stream stream-format
    [ [ string-lines ] 2dip pane-format ] do-pane-stream ;

M: pane-stream dispose drop ;

M: pane-stream stream-flush drop ;

M: pane-stream make-span-stream
    swap <style-stream> <ignore-close-stream> ;

! Character styles

MEMO: specified-font ( assoc -- font )
    #! We memoize here to avoid creating lots of duplicate font objects.
    [ <font> ] dip
    {
        [ font-name swap at "monospace" or >>name ]
        [
            font-style swap at {
                { f [ ] }
                { plain [ ] }
                { bold [ t >>bold? ] }
                { italic [ t >>italic? ] }
                { bold-italic [ t >>bold? t >>italic? ] }
            } case
        ]
        [ font-size swap at 12 or >>size ]
        [ foreground swap at black or >>foreground ]
        [ background swap at white or >>background ]
    } cleave ;

: apply-font-style ( style gadget -- style gadget )
    { font-name font-style font-size foreground background }
    pick extract-keys specified-font >>font ;

: apply-style ( style gadget key quot -- style gadget )
    [ pick at ] dip when* ; inline

: apply-presentation-style ( style gadget -- style gadget )
    presented [ <presentation> ] apply-style ;

: style-label ( style gadget -- gadget )
    apply-font-style
    apply-presentation-style
    nip ; inline

: <styled-label> ( style text -- gadget )
    <label> style-label ;

! Paragraph styles

: apply-wrap-style ( style pane -- style pane )
    wrap-margin [
        2dup <paragraph> >>prototype drop
        <paragraph> >>current
    ] apply-style ;

: apply-border-color-style ( style gadget -- style gadget )
    border-color [ solid-boundary ] apply-style ;

: apply-page-color-style ( style gadget -- style gadget )
    page-color [ solid-interior ] apply-style ;

: apply-border-width-style ( style gadget -- style gadget )
    border-width [ dup 2array <border> ] apply-style ;

: style-pane ( style pane -- pane )
    apply-border-width-style
    apply-border-color-style
    apply-page-color-style
    apply-presentation-style
    nip ;

TUPLE: nested-pane-stream < pane-stream style parent ;

: new-nested-pane-stream ( style parent class -- stream )
    new
        swap >>parent
        swap <pane> apply-wrap-style [ >>style ] [ >>pane ] bi* ;
    inline

: unnest-pane-stream ( stream -- child parent )
    dup ?nl
    dup style>>
    over pane>> smash-pane style-pane
    swap parent>> ;

TUPLE: pane-block-stream < nested-pane-stream ;

M: pane-block-stream dispose
    unnest-pane-stream write-gadget ;

M: pane-stream make-block-stream
    pane-block-stream new-nested-pane-stream ;

! Tables
: apply-table-gap-style ( style grid -- style grid )
    table-gap [ >>gap ] apply-style ;

: apply-table-border-style ( style grid -- style grid )
    table-border [ <grid-lines> >>boundary ]
    apply-style ;

: styled-grid ( style grid -- grid )
    <grid>
    f >>fill?
    apply-table-gap-style
    apply-table-border-style
    nip ;

TUPLE: pane-cell-stream < nested-pane-stream ;

M: pane-cell-stream dispose ?nl ;

M: pane-stream make-cell-stream
    pane-cell-stream new-nested-pane-stream ;

M: pane-stream stream-write-table
    [
        swap [ [ pane>> smash-pane ] map ] map
        styled-grid
    ] dip print-gadget ;

! Stream utilities
M: pack dispose drop ;

M: paragraph dispose drop ;

: gadget-write ( string gadget -- )
    swap dup empty?
    [ 2drop ] [ <label> text-theme add-gadget drop ] if ;

M: pack stream-write gadget-write ;

: gadget-bl ( style stream -- )
    swap " " <word-break-gadget> style-label add-gadget drop ;

M: paragraph stream-write
    swap " " split
    [ H{ } over gadget-bl ] [ over gadget-write ] interleave
    drop ;

: gadget-write1 ( char gadget -- )
    [ 1string ] dip stream-write ;

M: pack stream-write1 gadget-write1 ;

M: paragraph stream-write1
    over CHAR: \s =
    [ H{ } swap gadget-bl drop ] [ gadget-write1 ] if ;

: gadget-format ( string style stream -- )
    '[ _ swap <styled-label> _ swap add-gadget drop ] unless-empty ;

M: pack stream-format
    gadget-format ;

M: paragraph stream-format
    presented pick at [
        gadget-format
    ] [
        [ " " split ] 2dip
        [ gadget-bl ] [ gadget-format ] bi-curry bi-curry
        interleave
    ] if ;

: caret>mark ( pane -- pane )
    dup caret>> >>mark
    dup relayout-1 ;

GENERIC: sloppy-pick-up* ( loc gadget -- n )

M: pack sloppy-pick-up* ( loc gadget -- n )
    [ orientation>> ] [ children>> ] bi (fast-children-on) ;

M: gadget sloppy-pick-up*
    children>> [ contains-point? ] with find-last drop ;

M: f sloppy-pick-up*
    2drop f ;

: wet-and-sloppy ( loc gadget n -- newloc newgadget )
    swap nth-gadget [ loc>> v- ] keep ;

: sloppy-pick-up ( loc gadget -- path )
    2dup sloppy-pick-up* dup
    [ [ wet-and-sloppy sloppy-pick-up ] keep prefix ]
    [ 3drop { } ]
    if ;

: move-caret ( pane loc -- pane )
    over screen-loc v- over sloppy-pick-up >>caret
    dup relayout-1 ;

: begin-selection ( pane -- )
    f >>selecting?
    hand-loc get move-caret
    f >>mark
    drop ;

: extend-selection ( pane -- )
    hand-moved? [
        dup selecting?>> [
            hand-loc get move-caret
        ] [
            dup hand-clicked get child? [
                t >>selecting?
                dup hand-clicked set-global
                hand-click-loc get move-caret
                caret>mark
            ] when
        ] if
        dup dup caret>> gadget-at-path scroll>gadget
    ] when drop ;

: end-selection ( pane -- )
    f >>selecting?
    hand-moved? [
        [ com-copy-selection ] [ request-focus ] bi
    ] [
        relayout-1
    ] if ;

: select-to-caret ( pane -- )
    t >>selecting?
    dup mark>> [ caret>mark ] unless
    hand-loc get move-caret
    dup request-focus
    com-copy-selection ;

: pane-menu ( pane -- ) { com-copy } show-commands-menu ;

pane H{
    { T{ button-down } [ begin-selection ] }
    { T{ button-down f { S+ } 1 } [ select-to-caret ] }
    { T{ button-up f { S+ } 1 } [ end-selection ] }
    { T{ button-up } [ end-selection ] }
    { T{ drag } [ extend-selection ] }
    { copy-action [ com-copy ] }
    { T{ button-down f f 3 } [ pane-menu ] }
} set-gestures
