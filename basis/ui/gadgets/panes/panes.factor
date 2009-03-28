! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays hashtables io kernel namespaces sequences
strings quotations math opengl combinators memoize math.vectors
sorting splitting assocs classes.tuple models continuations
destructors accessors math.rectangles fry fonts ui.pens.solid
ui.images ui.gadgets ui.gadgets.private ui.gadgets.borders
ui.gadgets.buttons ui.gadgets.labels ui.gadgets.scrollers
ui.gadgets.paragraphs ui.gadgets.incremental ui.gadgets.packs
ui.gadgets.menus ui.clipboards ui.gestures ui.traverse ui.render
ui.text ui.gadgets.presentations ui.gadgets.grids ui.gadgets.tracks
ui.gadgets.icons ui.gadgets.grid-lines ui.baseline-alignment
colors io.styles ;
IN: ui.gadgets.panes

TUPLE: pane < track
output current input last-line prototype scrolls?
selection-color caret mark selecting? ;

TUPLE: pane-stream pane ;

C: <pane-stream> pane-stream

M: pane-stream stream-element-type drop +character+ ;

<PRIVATE

: clear-selection ( pane -- pane )
    f >>caret f >>mark ; inline

: prepare-last-line ( pane -- )
    [ last-line>> ] keep
    [ current>> f track-add ]
    [ input>> [ 1 track-add ] when* ] bi
    drop ; inline

: init-current ( pane -- pane )
    dup prototype>> clone >>current ; inline

: focus-input ( pane -- )
    input>> [ request-focus ] when* ;

: next-line ( pane -- )
    clear-selection
    [ input>> unparent ]
    [ init-current prepare-last-line ]
    [ focus-input ] tri ;

: pane-caret&mark ( pane -- caret mark )
    [ caret>> ] [ mark>> ] bi ; inline

: selected-children ( pane -- seq )
    [ pane-caret&mark sort-pair ] keep gadget-subtree ;

M: pane gadget-selection? pane-caret&mark and ;

M: pane gadget-selection ( pane -- string/f )
    selected-children gadget-text ;

: init-prototype ( pane -- pane )
    <shelf> +baseline+ >>align >>prototype ; inline

: init-output ( pane -- pane )
    <incremental> [ >>output ] [ f track-add ] bi ; inline

: pane-theme ( pane -- pane )
    1 >>fill
    selection-color >>selection-color ; inline

: init-last-line ( pane -- pane )
    horizontal <track> 0 >>fill +baseline+ >>align
    [ >>last-line ] [ 1 track-add ] bi
    dup prepare-last-line ; inline

GENERIC: draw-selection ( loc obj -- )

: if-fits ( rect quot -- )
    [ clip get over contains-rect? ] dip [ drop ] if ; inline

M: gadget draw-selection ( loc gadget -- )
    swap offset-rect [
        rect-bounds gl-fill-rect
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
            [ loc>> vneg ] keep selected-children
            [ draw-selection ] with each
        ] bi
    ] [ drop ] if ;

: scroll-pane ( pane -- )
    dup scrolls?>> [ scroll>bottom ] [ drop ] if ;

: smash-line ( current -- gadget )
    dup children>> {
        { [ dup empty? ] [ 2drop "" <label> ] }
        { [ dup length 1 = ] [ nip first ] }
        [ drop ]
    } cond ;

: pane-nl ( pane -- )
    [
        [ current>> [ unparent ] [ smash-line ] bi ] [ output>> ] bi
        add-incremental
    ] [ next-line ] bi ;

: ?pane-nl ( pane -- )
    [ dup current>> children>> empty? [ pane-nl ] [ drop ] if ]
    [ pane-nl ] bi ;

: smash-pane ( pane -- gadget ) [ pane-nl ] [ output>> smash-line ] bi ;

: pane-write ( seq pane -- )
    [ pane-nl ] [ current>> stream-write ]
    bi-curry interleave ;

: pane-format ( seq style pane -- )
    [ nip pane-nl ] [ current>> stream-format ]
    bi-curry bi-curry interleave ;

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

PRIVATE>

: new-pane ( input class -- pane )
    [ vertical ] dip new-track
        swap >>input
        pane-theme
        init-prototype
        init-output
        init-current
        init-last-line ; inline

: <pane> ( -- pane ) f pane new-pane ;

GENERIC: write-gadget ( gadget stream -- )

M: pane-stream write-gadget ( gadget pane-stream -- )
    pane>> current>> swap add-gadget drop ;

M: style-stream write-gadget
    stream>> write-gadget ;

: print-gadget ( gadget stream -- )
    [ write-gadget ] [ nip stream-nl ] 2bi ;

: gadget. ( gadget -- )
    output-stream get print-gadget ;

: pane-clear ( pane -- )
    clear-selection
    [ output>> clear-incremental ]
    [ current>> clear-gadget ]
    bi ;

: with-pane ( pane quot -- )
    [ [ scroll>top ] [ pane-clear ] [ <pane-stream> ] tri ] dip
    with-output-stream* ; inline

: make-pane ( quot -- gadget )
    [ <pane> ] dip [ with-pane ] [ drop smash-pane ] 2bi ; inline

TUPLE: pane-control < pane quot ;

M: pane-control model-changed ( model pane-control -- )
    [ value>> ] [ dup quot>> ] bi*
    '[ _ call( value -- ) ] with-pane ;

: <pane-control> ( model quot -- pane )
    f pane-control new-pane
        swap >>quot
        swap >>model ;

! Character styles
<PRIVATE

MEMO: specified-font ( assoc -- font )
    #! We memoize here to avoid creating lots of duplicate font objects.
    [ monospace-font <font> ] dip
    {
        [ font-name swap at >>name ]
        [
            font-style swap at {
                { f [ ] }
                { plain [ ] }
                { bold [ t >>bold? ] }
                { italic [ t >>italic? ] }
                { bold-italic [ t >>bold? t >>italic? ] }
            } case
        ]
        [ font-size swap at >>size ]
        [ foreground swap at >>foreground ]
        [ background swap at >>background ]
    } cleave
    derive-font ;

: apply-font-style ( style gadget -- style gadget )
    { font-name font-style font-size foreground background }
    pick extract-keys specified-font >>font ;

: apply-style ( style gadget key quot -- style gadget )
    [ pick at ] dip when* ; inline

: apply-presentation-style ( style gadget -- style gadget )
    presented [ <presentation> ] apply-style ;

: apply-image-style ( style gadget -- style gadget )
    image [ nip <image-name> <icon> ] apply-style ;

: apply-background-style ( style gadget -- style gadget )
    background [ <solid> >>interior ] apply-style ;

: style-label ( style gadget -- gadget )
    apply-font-style
    apply-background-style
    apply-presentation-style
    apply-image-style
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
    border-color [ <solid> >>boundary ] apply-style ;

: apply-page-color-style ( style gadget -- style gadget )
    page-color [ <solid> >>interior ] apply-style ;

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
    [ [ style>> ] [ pane>> smash-pane ] bi style-pane ] [ parent>> ] bi ;

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

M: pane-cell-stream dispose drop ;

M: pane-stream make-cell-stream
    pane-cell-stream new-nested-pane-stream ;

M: pane-stream stream-write-table
    [
        swap [ [ pane>> smash-pane ] map ] map
        styled-grid
    ] dip write-gadget ;

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

: empty-output? ( string style -- ? )
    [ empty? ] [ image swap key? not ] bi* and ;

: gadget-format ( string style stream -- )
    [ [ empty-output? ] 2keep ] dip
    '[ _ _ swap <styled-label> _ swap add-gadget drop ] unless ;

M: pack stream-format
    gadget-format ;

M: paragraph stream-format
    over { presented image } [ swap key? ] with any? [
        gadget-format
    ] [
        [ " " split ] 2dip
        [ gadget-bl ] [ gadget-format ] bi-curry bi-curry
        interleave
    ] if ;

: caret>mark ( pane -- )
    dup caret>> >>mark relayout-1 ;

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

: move-caret ( pane loc -- )
    over screen-loc v- over sloppy-pick-up >>caret
    relayout-1 ;

: begin-selection ( pane -- )
    f >>selecting?
    dup hand-loc get move-caret
    f >>mark
    drop ;

: extend-selection ( pane -- )
    hand-moved? [
        [
            dup selecting?>> [
                hand-loc get move-caret
            ] [
                dup hand-clicked get child? [
                    t >>selecting?
                    [ hand-clicked set-global ]
                    [ hand-click-loc get move-caret ]
                    [ caret>mark ]
                    tri
                ] [ drop ] if
            ] if
        ] [ dup caret>> gadget-at-path scroll>gadget ] bi
    ] [ drop ] if ;

: end-selection ( pane -- )
    f >>selecting?
    hand-moved?
    [ [ com-copy-selection ] [ request-focus ] bi ]
    [ [ relayout-1 ] [ focus-input ] bi ]
    if ;

: select-to-caret ( pane -- )
    t >>selecting?
    [ dup mark>> [ dup caret>mark ] unless hand-loc get move-caret ]
    [ com-copy-selection ]
    [ request-focus ]
    tri ;

: pane-menu ( pane -- ) { com-copy } show-commands-menu ;

PRIVATE>

pane H{
    { T{ button-down } [ begin-selection ] }
    { T{ button-down f { S+ } 1 } [ select-to-caret ] }
    { T{ button-up f { S+ } 1 } [ end-selection ] }
    { T{ button-up } [ end-selection ] }
    { T{ drag } [ extend-selection ] }
    { copy-action [ com-copy ] }
    { T{ button-down f f 3 } [ pane-menu ] }
} set-gestures
