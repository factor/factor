! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays gadgets gadgets-buttons gadgets-labels
gadgets-layouts gadgets-panes gadgets-presentations
gadgets-scrolling gadgets-theme generic hashtables help
inspector kernel math namespaces prettyprint sequences words ;
IN: gadgets-inspector

SYMBOL: components

H{ } clone components set-global

: get-components ( class -- assoc )
    components get-global hash [
        { { "Slots" [ describe ] } }
    ] unless* ;

{
    { "Definition" [ see ] }
    { "Documentation" [ word-help (help) ] }
    { "Calls in" [ usage. ] }
    { "Calls out" [ uses. ] }
    { "Links in" [ links-in. ] }
    { "Links out" [ links-out. ] }
    { "Properties" [ word-props describe ] }
} \ word components get-global set-hash

{
    { "Article" [ help ] }
    { "Links in" [ links-in. ] }
    { "Links out" [ links-out. ] }
} \ link components get-global set-hash

{
    { "Call stack" [ continuation-call callstack. ] }
    { "Data stack" [ continuation-data stack. ] }
    { "Retain stack" [ continuation-retain stack. ] }
    { "Name stack" [ continuation-name stack. ] }
    { "Catch stack" [ continuation-catch stack. ] }
} \ continuation components get-global set-hash

TUPLE: book page pages ;

: show-page ( key book -- )
    dup book-page unparent
    [ book-pages assoc ] keep
    [ set-book-page ] 2keep
    add-gadget ;

C: book ( pages -- book )
    dup delegate>gadget
    [ set-book-pages ] 2keep
    [ >r first first r> show-page ] keep ;

M: book pref-dim* ( book -- dim ) book-page pref-dim ;

M: book layout* ( book -- )
    dup rect-dim swap book-page set-gadget-dim ;

: component-pages ( obj -- assoc )
    dup class get-components
    [ first2 swapd make-pane <scroller> 2array ] map-with ;

: <tab> ( name book -- button )
    dupd [ show-page drop ] curry curry
    >r <label> r> <bevel-button> ;

: tabs ( assoc book gadget -- )
    >r swap [ first swap <tab> ] map-with r> add-gadgets ;

TUPLE: inspector object history tabs ;

: save-current ( inspector -- )
    dup inspector-object swap inspector-history push ;

: (inspect) ( obj inspector -- )
    [ set-inspector-object ] 2keep
    dup inspector-tabs clear-gadget
    >r component-pages dup <book> r>
    [ @center frame-add ] 2keep inspector-tabs tabs ;

: inspect ( obj inspector -- ) dup save-current (inspect) ;

: find-inspector [ inspector? ] find-parent ;

: go-back ( inspector -- )
    dup inspector-history dup empty?
    [ 2drop ] [ pop swap inspect ] if ;

: <back-button> ( -- gadget )
    "<" <label> [ find-inspector go-back ] <bevel-button> ;

C: inspector ( obj history? -- inspector )
    V{ } clone over set-inspector-history
    dup delegate>frame [
        swap [ <back-button> , ] when
        <shelf> dup pick set-inspector-tabs ,
    ] { } make make-shelf dup highlight-theme
    over @top frame-add
    [ (inspect) ] keep ;

: inspector-window ( obj -- )
    t <inspector> "Inspector" open-window ;

M: object show-object ( object button -- )
    find-inspector [ inspect ] [ inspector-window ] if* ;
