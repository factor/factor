! Copyright (C) 2005, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs classes combinators destructors
documents.private fonts fry io io.styles kernel locals
math.rectangles math.vectors memoize models namespaces sequences
sorting splitting strings ui.baseline-alignment ui.clipboards
ui.gadgets ui.gadgets.borders ui.gadgets.grid-lines
ui.gadgets.grids ui.gadgets.icons ui.gadgets.incremental
ui.gadgets.labels ui.gadgets.menus ui.gadgets.packs
ui.gadgets.paragraphs ui.gadgets.presentations
ui.gadgets.private ui.gadgets.scrollers ui.gadgets.tracks
ui.gestures ui.images ui.pens.solid ui.render ui.theme
ui.traverse ;
FROM: io.styles => foreground background ;
FROM: ui.gadgets.wrappers => <wrapper> ;
IN: ui.gadgets.panes

TUPLE: pane < track
    output current input last-line prototype scrolls?
    selection-color caret mark selecting? ;

TUPLE: pane-stream pane ;
INSTANCE: pane-stream output-stream

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

: selected-subtree ( pane -- seq )
    [ pane-caret&mark sort-pair ] keep gadget-subtree ;

M: pane gadget-selection? pane-caret&mark and ;

M: pane gadget-selection ( pane -- string/f )
    selected-subtree gadget-text ;

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

M: pane selected-children
    dup gadget-selection? [
        [ selected-subtree leaves ]
        [ selection-color>> ]
        bi
    ] [ drop f f ] if ;

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
    [ [ split-lines ] dip pane-write ] do-pane-stream ;

M: pane-stream stream-format
    [ [ split-lines ] 2dip pane-format ] do-pane-stream ;

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

GENERIC: gadget-alt-text ( gadget -- string )

M: object gadget-alt-text
    class-of name>> "( " " )" surround ;

GENERIC: write-gadget ( gadget stream -- )

M: object write-gadget
    [ gadget-alt-text ] dip stream-write ;

M: filter-writer write-gadget
    stream>> write-gadget ;

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

<PRIVATE

! Character styles

MEMO:: specified-font ( name style size foreground background -- font )
    ! We memoize here to avoid creating lots of duplicate font objects.
    monospace-font
        name [ >>name ] when*
        style {
            { f [ ] }
            { plain [ ] }
            { bold [ t >>bold? ] }
            { italic [ t >>italic? ] }
            { bold-italic [ t >>bold? t >>italic? ] }
        } case
        size [ >>size ] when*
        foreground [ >>foreground ] when*
        background [ >>background ] when* ;

: apply-font-style ( style gadget -- style gadget )
    over {
        [ font-name of ]
        [ font-style of ]
        [ font-size of ]
        [ foreground of ]
        [ background of ]
    } cleave specified-font >>font ;

: apply-style ( style gadget key quot -- style gadget )
    [ pick at ] dip when* ; inline

: apply-presentation-style ( style gadget -- style gadget )
    presented [ <presentation> ] apply-style ;

: apply-image-style ( style gadget -- style gadget )
    image-style [ nip <image-name> <icon> ] apply-style ;

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

: apply-inset-style ( style gadget -- style gadget )
    inset [ <border> ] apply-style ;

: style-pane ( style pane -- pane )
    apply-inset-style
    apply-border-color-style
    apply-page-color-style
    apply-presentation-style
    nip ;

TUPLE: nested-pane-stream < pane-stream style parent ;

: new-nested-pane-stream ( style parent class -- stream )
    new
        swap >>parent
        swap <pane> apply-wrap-style [ >>style ] [ >>pane ] bi* ; inline

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
    table-border [ <grid-lines> >>boundary ] apply-style ;

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
    [ 2drop ] [ <label> monospace-font >>font add-gadget drop ] if ;

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
    [ empty? ] [ image-style swap key? not ] bi* and ;

: gadget-format ( string style stream -- )
    [ [ empty-output? ] 2keep ] dip
    '[ _ _ swap <styled-label> _ swap add-gadget drop ] unless ;

M: pack stream-format
    gadget-format ;

M: paragraph stream-format
    over { presented image-style } [ swap key? ] with any? [
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
    [ orientation>> ] [ children>> ] bi
    [ loc>> ] (fast-children-on) ;

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
    dup hand-loc get-global move-caret
    f >>mark
    drop ;

: extend-selection ( pane -- )
    hand-moved? [
        [
            dup selecting?>> [
                hand-loc get-global move-caret
            ] [
                dup hand-clicked get-global child? [
                    t >>selecting?
                    [ hand-clicked set-global ]
                    [ hand-click-loc get-global move-caret ]
                    [ caret>mark ]
                    tri
                ] [ drop ] if
            ] if
        ] [ dup caret>> gadget-at-path scroll>gadget ] bi
    ] [ drop ] if ;

: end-selection ( pane -- )
    dup selecting?>> hand-moved? or
    [ f >>selecting? ] dip
    [ [ com-copy-selection ] [ request-focus ] bi ]
    [ [ relayout-1 ] [ focus-input ] bi ]
    if ;

: select-to-caret ( pane -- )
    t >>selecting?
    [ dup mark>> [ dup caret>mark ] unless hand-loc get-global move-caret ]
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
    { T{ drag { # 1 } } [ extend-selection ] }
    { copy-action [ com-copy ] }
    { T{ button-down f f 3 } [ pane-menu ] }
} set-gestures

GENERIC: content-gadget ( object -- gadget/f )
M: object content-gadget drop f ;
