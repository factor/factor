USING: accessors colors combinators fonts grouping images kernel locals math
sequences splitting tools.test windows.uniscribe windows.uniscribe.private ;
IN: windows.uniscribe.compositing.tests

:: blank-pixels ( background selection-color -- pixels )
    monospace-font 0 0 0 0 <rgba> >>foreground
    background >>background
    "  " 0 2 selection-color <selection> cached-script-string
    script-string>image bitmap>> 4 group ;

! A translucent background survives even where no glyph is drawn.
{ t } [
    monospace-font 0 0 1 0.5 <rgba> >>background
    " " cached-script-string script-string>image bitmap>> 4 group
    [ B{ 0 0 255 128 } = ] all?
] unit-test

! Custom backgrounds retain their actual RGB and alpha on transparent text.
{ t } [
    0 0 0 0 <rgba> 1 0 0 0.5 <rgba> blank-pixels
    [ B{ 255 0 0 128 } = ] all?
] unit-test

{ t } [
    0 0 0 0 <rgba> 0 0 1 0.5 <rgba> blank-pixels
    [ B{ 0 0 255 128 } = ] all?
] unit-test

! Source-over selection compositing includes the base background.
{ t } [
    0 0 1 0.5 <rgba> 1 0 0 0.5 <rgba> blank-pixels
    [ B{ 170 0 85 191 } = ] all?
] unit-test

{ t } [
    COLOR: blue 0 0 0 0 <rgba> blank-pixels
    [ B{ 0 0 255 255 } = ] all?
] unit-test

! A logical range crossing an LTR/RTL boundary has disjoint visual spans.
{ t } [
    monospace-font "abc אבג xyz" 1 5 COLOR: red <selection>
    cached-script-string selection-columns
    [ 1 = ] split-when [ empty? not ] count 3 =
] unit-test

! Glyph coverage modulates foreground alpha without discarding background alpha.
{ t t } [
    monospace-font 40 >>size 1 0 0 0.5 <rgba> >>foreground
    0 0 1 0.5 <rgba> >>background "M" cached-script-string
    script-string>image bitmap>> 4 group
    [ [ B{ 170 0 85 191 } = ] any? ]
    [ [ last dup 128 >= swap 191 <= and ] all? ] bi
] unit-test

:: bidi-selection-pixels? ( -- ? )
    monospace-font 0 0 0 0 <rgba> >>foreground
    0 0 0 0 <rgba> >>background
    "abc \u0005d0\u0005d1\u0005d2 xyz" 1 5 COLOR: red <selection> cached-script-string :> layout
    layout selection-columns :> columns
    layout script-string>image bitmap>> 4 group
    [ :> i
        i columns length mod columns nth 1 =
        [ B{ 255 0 0 255 } ] [ B{ 0 0 0 0 } ] if =
    ] map-index [ ] all? ;

{ t } [ bidi-selection-pixels? ] unit-test
