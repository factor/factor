! Copyright (C) 2015-2017 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays code combinators.short-circuit kernel
locals math math.order math.vectors models sequences splitting
ui.gadgets ui.gadgets.borders ui.gadgets.buttons.round
ui.gadgets.labels ui.gadgets.packs ui.gadgets.packs.private
ui.gestures ui.pens.gradient-rounded ui.pens.solid
ui.tools.environment.cell ui.tools.environment.theme ;
FROM: code => call ;
FROM: models => change-model ;
IN: ui.tools.environment.tree

TUPLE: tree < pack ;
TUPLE: tree-control < pack ;
TUPLE: tree-toolbar < tree-control ;
TUPLE: path-display < tree-control selected ;
TUPLE: special-pile < pack ;
TUPLE: path-item < pack  word ;
TUPLE: path-cell < border  word? ;

: <special-pile> ( -- pack )
    special-pile new vertical >>orientation ;

: center-point ( gadget -- x )
    [ [ parent>> loc>> ] [ loc>> ] bi v+ ] [ dim>> ] bi [ first ] bi@ 2 /i + ;

M:: special-pile layout* ( pack -- )
    pack call-next-method
    pack children>> first2 :> ( shelf cell )
    shelf layout
    shelf children>> empty? [
        shelf children>> [ first ] [ last ] bi [ children>> last center-point ] bi@ :> ( a b )
        cell pref-dim first2 [ b a - 20 + max ] dip 2array cell dim<<
        a b + 2 /i cell dim>> first 2 /i - dup neg?
        [ neg shelf loc>> second 2array shelf loc<< ]
        [ cell loc>> second 2array cell loc<< ] if
    ] unless ;

: <quoted-cell> ( cell -- pile )
    <special-pile> <shelf> rot add-gadget add-gadget <gadget> { 0 6 } >>dim add-gadget ;

:: build-tree ( node selection -- pile )
    <special-pile> { 0 1 } >>gap
        <shelf> { 8 0 } >>gap 1 >>align
            node contents>> [ selection build-tree ] map add-gadgets add-gadget
        node selection <cell> add-gadget
    node quoted?>> [ <quoted-cell> ] when ;

: <tree> ( word -- pile )
    tree new horizontal >>orientation swap >>model { 15 0 } >>gap 1 >>align ;

M:: tree model-changed ( model tree -- )
    tree clear-gadget
    tree model value>> [ word? ] find-parent ?add-words
    contents>> [ model build-tree ] map add-gadgets drop ;

M: tree-control pref-dim*
    call-next-method first2 20 max 2array ;

: <tree-toolbar> ( model -- gadget )
    tree-toolbar new horizontal >>orientation { 5 0 } >>gap swap >>model ;

:: add-button ( toolbar cond-quot color letter action-quot tooltip -- toolbar )
    toolbar dup control-value cond-quot call( x -- ? )
    [ color letter [ drop toolbar model>> action-quot change-model ] ]
    [ inactive-background "" [ drop ] ] if <round-button>
    tooltip >>tooltip add-gadget ;

M:: tree-toolbar model-changed ( model tree-toolbar -- )
    tree-toolbar dup clear-gadget
    model value>> [ word? ] find-parent ?add-words drop
    model value>> node? [
        [ top-node? ] dark-background "I" [ introduce ?change-node-type ]
            "Convert cell into an input cell    ( Control I )" add-button
        [ top-node? ] yellow-background "G" [ getter ?change-node-type ]
            "Convert cell into a get cell    ( Control G )" add-button
        [ top-node? ] white-background "T" [ text ?change-node-type ]
            "Convert cell into a text cell    ( Control T )" add-button
        <gadget> add-gadget
        [ drop t ] green-background "W" [ call ?change-node-type ]
            "Convert cell into a word cell    ( Control W )" add-button
        <gadget> add-gadget
        [ bottom-node? ] yellow-background "S" [ setter ?change-node-type ]
             "Convert cell into a set cell    ( Control S )" add-button
        [ [ bottom-node? ] [ no-return? ] [ return? ] tri or and ]
            dark-background "O" [ return ?change-node-type ]
            "Convert cell into an output cell    ( Control O )" add-button
        <gadget> { 20 0 } >>dim add-gadget
        model value>> bottom-node?
            [ inactive-background "" [ drop ] ]
            [ blue-background model value>> quoted?>> "︾" "︽" ?
              [ drop model [ (un)quote ] change-model ] ] if <round-button>
            model value>> quoted?>> "Unquote" "Quote" ? "    ( Control Q )" append 
            >>tooltip add-gadget
        <gadget> add-gadget
        [ leftmost-node? not ] blue-background "←" [ left exchange-node-side ]
            "Exchange cell and cell on the left    ( Command ← )" add-button
        [ rightmost-node? not ] blue-background "→" [ right exchange-node-side ]
            "Exchange cell and cell on the right    ( Command → )" add-button
        <gadget> add-gadget
        [ parent>> { [ word? ] [ variadic? ] } 1|| ]
            blue-background "⇐" [ left insert-node-side ]
            "Insert new cell on the left    ( Option ← )" add-button
        [ parent>> { [ word? ] [ variadic? ] } 1|| ]
            blue-background "⇒" [ right insert-node-side ]
            "Insert new cell on the right    ( Option → )" add-button
        [ drop t ] blue-background "⇓" [ insert-new-parent ]
            "Insert new cell below    ( Option ↓ )" add-button
        <gadget> add-gadget
        [ bottom-node? not ] red-background "↓" [ replace-parent ]
            "Replace cell below    ( Control R )" add-button
        [ drop t ]
            red-background "✕" [ remove-element ]
            "Delete cell and everything above    ( Control D )" add-button
    ] when drop ;

: path-cell-colors ( cell -- bg-color text-color )
    word?>> [ green-background dark-text-colour ]
    [ blue-background dark-text-colour ] if ;

: <path-cell> ( name word? -- node )
    path-cell new { 5 0 } >>size { 0 18 } >>min-dim
    swap >>word? swap " " append <label> set-small-font add-gadget
    dup path-cell-colors <gradient-arrow> >>interior ;

: <path-item> ( factor-word -- gadget )
    dup [ vocabulary>> "." split [ f <path-cell> ] map ] [ name>> t <path-cell> ] bi suffix 
    path-item new swap add-gadgets swap >>word horizontal >>orientation { 7 0 } >>gap ;

: <path-display> ( model -- gadget )
    path-display new vertical >>orientation { 0 5 } >>gap swap >>model ;

M:: path-display model-changed ( model path-display -- )
    path-display dup clear-gadget
    model value>> call? [
        model value>> target>> number? [
            model value>> completion>>
            [ model value>> completion>> [ <path-item> ] map add-gadgets ]
            [ model value>> target>> [ <path-item> add-gadget ] when* ] if
        ] unless
    ] when drop ;

: <tree-editor> ( word -- gadget )
    <pile> { 0 30 } >>gap 1/2 >>align swap <model>
    [ <tree-toolbar> ] [ <tree> ] [ <path-display> ] tri 3array add-gadgets ;

: select-nothing ( tree -- )
    model>> [ [ node? not ] find-parent ] change-model ;

: choose-word ( path-item -- )
    [ word>> ] [ parent>> model>> ] bi
    [ swap >>target dup target>> name>> short-name >>name f >>completion ] with change-model ;

: select-word ( path-item -- )
    dark-background second <solid> >>interior relayout-1 ;

: deselect-word ( path-item -- )
    f >>interior relayout-1 ;

tree H{
    { T{ button-down } [ select-nothing ] }
} set-gestures

path-item H{
    { T{ button-down } [ choose-word ] }
} set-gestures
