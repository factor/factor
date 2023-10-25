! Copyright (C) 2005, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs classes combinators destructors
documents.private fonts io io.styles kernel math math.rectangles
math.vectors models models.range namespaces sequences sets
sorting splitting strings ui.baseline-alignment ui.clipboards
ui.gadgets ui.gadgets.borders ui.gadgets.grid-lines
ui.gadgets.grids ui.gadgets.icons ui.gadgets.incremental
ui.gadgets.labels ui.gadgets.menus ui.gadgets.packs
ui.gadgets.paragraphs ui.gadgets.presentations
ui.gadgets.private ui.gadgets.scrollers ui.gadgets.tracks
ui.gestures ui.images ui.pens.solid ui.render ui.theme
ui.traverse unicode ;
FROM: io.styles => foreground background ;
FROM: ui.gadgets.wrappers => <wrapper> ;
IN: ui.gadgets.panes

TUPLE: pane < track
    output current input last-line prototype scrolls?
    selection-color caret mark selecting? ;

TUPLE: pane-stream pane parent ;
INSTANCE: pane-stream output-stream

: <pane-stream> ( pane -- pane-stream )
    f pane-stream boa ;

M: pane-stream stream-element-type drop +character+ ;

DEFER: write-gadget

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
    [ input>> unparent ]
    [ init-current prepare-last-line ]
    [ focus-input ] tri ;

: pane-caret&mark ( pane -- caret mark )
    [ caret>> ] [ mark>> ] bi ; inline

: selected-subtree ( pane -- seq )
    [ pane-caret&mark sort-pair ] keep gadget-subtree ;

M: pane gadget-selection? pane-caret&mark and ;

M: pane gadget-selection selected-subtree gadget-text ;

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

GENERIC: pane-label ( pane -- label )

M: pane pane-label drop "" <label> ;

: smash-line ( pane current -- gadget )
    dup children>> {
        { [ dup empty? ] [ 2drop pane-label ] }
        { [ dup length 1 = ] [ 2nip first ] }
        [ drop nip ]
    } cond ;

: pane-nl ( pane -- )
    [
        [ dup current>> [ unparent ] [ smash-line ] bi ] [ output>> ] bi
        add-incremental
    ] [ next-line ] bi ;

GENERIC: smash-pane ( pane -- gadget )

M: pane smash-pane
    [ pane-nl ] [ dup output>> smash-line ] bi ;

GENERIC: pane-line ( str style gadget -- )

: pane-format ( lines style pane -- )
    [ nip pane-nl ] [ current>> pane-line ]
    bi-curry bi-curry interleave ;

: pane-write ( lines pane -- )
    H{ } swap pane-format ;

: pane-write1 ( char pane -- )
    [ 1string H{ } ] dip current>> pane-line ;

:: do-pane-stream ( pane-stream quot -- )
    pane-stream pane>> :> pane
    pane find-scroller :> scroller
    scroller [
        model>> dependencies>> second {
            [ range-value ]
            [ range-page-value + ]
            [ range-max-value >= ]
        } cleave
    ] [ f ] if* :> bottom?
    pane quot call
    pane scrolls?>> bottom? and scroller and [
        scroller {
            [ model>> dependencies>> first2 [ range-value ] [ range-max-value ] bi* 2array ]
            [ set-scroll-position ]
        } cleave
    ] when ; inline

M: pane-stream stream-nl
    [ pane-nl ] do-pane-stream ;

M: pane-stream stream-write1
    [ pane-write1 ] do-pane-stream ;

: split-pane ( str quot: ( str -- ) -- )
    '[
        dup length 3639 >
        [ 3639 over last-grapheme-from cut-slice ] [ f ] if
        swap "" like ?split-lines @ dup
    ] loop drop ; inline

M: pane-stream stream-write
    [ '[ _ pane-write ] split-pane ] do-pane-stream ;

M: pane-stream stream-format
    [ '[ _ _ pane-format ] split-pane ] do-pane-stream ;

M: pane-stream dispose
    dup parent>> [
        [ pane>> smash-pane ] dip write-gadget
    ] [ drop ] if* ;

! M: pane-stream dispose drop ;

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

M: pane-stream write-gadget
    [ current>> swap add-gadget drop ] do-pane-stream ;

: print-gadget ( gadget stream -- )
    [ write-gadget ] [ nip stream-nl ] 2bi ;

: gadget. ( gadget -- )
    output-stream get print-gadget ;

: clear-pane ( pane -- )
    clear-selection
    [ output>> clear-incremental ]
    [ current>> clear-gadget ]
    bi ;

: with-pane ( pane quot -- )
    over [
        [ [ scroll>top ] [ clear-pane ] [ <pane-stream> ] tri ] dip
        with-output-stream*
    ] dip scroll-pane ; inline

: make-pane ( quot -- gadget )
    [ <pane> ] dip '[ _ with-pane ] keep smash-pane ; inline

TUPLE: pane-control < pane quot ;

M: pane-control model-changed
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

: apply-character-style ( style gadget -- gadget )
    apply-font-style
    apply-background-style
    apply-image-style
    apply-presentation-style
    nip ; inline

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

: apply-paragraph-style ( style pane -- pane )
    apply-inset-style
    apply-border-color-style
    apply-page-color-style
    apply-presentation-style
    nip ;

: remove-paragraph-styles ( style -- style' )
    [
        HS{
            wrap-margin border-color page-color inset presented
        } in?
    ] reject-keys ;

TUPLE: styled-pane < pane style ;

: <styled-pane> ( style -- pane )
    f styled-pane new-pane apply-wrap-style swap >>style ;

M: styled-pane smash-pane
    [ style>> ] [ call-next-method apply-paragraph-style ] bi ;

: <styled-pane-stream> ( style pane-stream -- styled-stream )
    over
    [ <styled-pane> ]
    [ pane-stream boa ]
    [ remove-paragraph-styles <style-stream> ] tri* ;

: make-styled-pane ( style quot -- gadget )
    [ <styled-pane> ] dip '[ _ with-pane ] keep smash-pane ; inline

M: pane-stream make-block-stream
    <styled-pane-stream> ;

! Tables

: apply-table-gap-style ( style grid -- style grid )
    table-gap [ >>gap ] apply-style ;

: apply-table-border-style ( style grid -- style grid )
    table-border [ <grid-lines> >>boundary ] apply-style ;

: <styled-grid> ( style grid -- grid )
    <grid>
    f >>fill?
    apply-table-gap-style
    apply-table-border-style
    apply-paragraph-style ;

M: pane-stream make-cell-stream
    drop f <styled-pane-stream> ;

M: pane-stream stream-write-table
    [
        swap [ [ stream>> pane>> smash-pane ] map ] map
        <styled-grid>
    ] dip write-gadget ;

! Stream utilities

: pane-bl ( style gadget -- )
    swap " " <word-break-gadget> apply-character-style add-gadget drop ;

TUPLE: styled-label < label style ;

: <styled-label> ( style text -- gadget )
    styled-label new-label over >>style
    apply-font-style
    apply-background-style
    apply-image-style
    apply-presentation-style
    nip ;

M: styled-pane pane-label style>> "" <styled-label> ;

: find-styled-label ( gadget -- styled-label/f )
    dup styled-label? [
        children>> ?last [ find-styled-label ] [ f ] if*
    ] unless ;

: pane-text ( string style gadget -- )
    dup find-styled-label [ pick over style>> = ] [ f f ] if* [
        2nip [ prepend ] change-text relayout
    ] [
        drop [ swap <styled-label> ] [ swap add-gadget drop ] bi*
    ] if ;

M: pack pane-line pane-text ;

M: paragraph pane-line
    { presented image-style } pick '[ _ key? ] any? [
        pane-text
    ] [
        [ split-words ] 2dip
        [ pane-bl ] [ pane-text ] bi-curry bi-curry
        interleave
    ] if ;

: caret>mark ( pane -- )
    dup caret>> >>mark relayout-1 ;

GENERIC: sloppy-pick-up* ( loc gadget -- n )

M: pack sloppy-pick-up*
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
