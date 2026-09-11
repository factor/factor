USING: accessors arrays assocs cache destructors fonts fonts.shaping kernel locals
math namespaces sequences strings tools.test windows.directwrite
windows.directwrite.indexed windows.directwrite.render ;
IN: windows.directwrite.indexed.tests

! Visibility is based on ink, including overhang from earlier blocks, and
! spatial lookup must preserve the original paint order.
: test-regions ( -- index )
    directwrite-glyph-index new {
        T{ directwrite-glyph-region { left 0 } { right 1000 } { max-right 1000 } { order 1 } }
        T{ directwrite-glyph-region { left 100 } { right 200 } { max-right 1000 } { order 0 } }
        T{ directwrite-glyph-region { left 1100 } { right 1200 } { max-right 1200 } { order 2 } }
    } >>regions ;

{ { 0 1 } } [ test-regions 150 160 visible-directwrite-regions [ order>> ] map ] unit-test
{ { 1 } } [ test-regions 900 950 visible-directwrite-regions [ order>> ] map ] unit-test
{ { } } [ test-regions 1001 1099 visible-directwrite-regions ] unit-test

! Complex text and explicit RTL paragraphs retain native painting.
{ f f } [
    [
        monospace-font 5000 CHAR: a <string> "אבג" append <directwrite-layout>
        &dispose glyph-index>>
        monospace-font right-to-left font-with-direction
        5000 CHAR: a <string> <directwrite-layout> &dispose glyph-index>>
    ] with-destructors
] unit-test

! A selected layout owns a reference to the same captured glyphs and can
! still render after the plain layout is evicted from the native cache.
{ t t f t } [
    [let
        monospace-font :> font
        5000 CHAR: a <string> :> text
        font text cached-directwrite-layout :> plain
        font text 0 20 font foreground>> <selection> <directwrite-layout> :> selected
        plain glyph-index>> :> index
        selected glyph-index>> index eq?
        font text directwrite-layout-key cached-directwrite-layouts get-global delete-at
        index owners>> 1 =
        index disposed>>
        selected { 0 0 } { 32 15 } directwrite-layout>region-image drop
        selected dispose
        index disposed>>
    ]
] unit-test

! Distinct equal strings share native storage; an alias hit must keep its
! owning cache entry alive. Mutating the string must invalidate that alias.
{ t t t t } [
    [let
        monospace-font :> font
        5001 CHAR: a <string> :> first-text
        first-text clone :> second-text
        font first-text cached-directwrite-layout :> original
        original font second-text cached-directwrite-layout eq?
        12 [
            font second-text cached-directwrite-layout drop
            cached-directwrite-layouts get-global purge-cache
            directwrite-layout-aliases get-global purge-cache
        ] times
        original disposed>> not
        CHAR: c 0 first-text set-nth
        font second-text cached-directwrite-layout string>> second-text =
        CHAR: b 0 second-text set-nth
        original font second-text cached-directwrite-layout eq? not
    ]
] unit-test
