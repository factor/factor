USING: accessors alien.c-types alien.data arrays colors combinators
 destructors fonts grouping images kernel locals math math.vectors namespaces sequences strings tools.test ui.text ui.text.private ui.text.uniscribe
 windows.offscreen windows.uniscribe windows.uniscribe.private windows.usp10 ;
IN: windows.uniscribe.overhang.tests

: overhang-font ( name -- font )
    <font> 48 >>size COLOR: white >>foreground
    0 0 0 0 <rgba> >>background ;

:: wide-reference ( script -- image )
    [ :> dc
        script dc configure-script-dc
        dc script string>> make-ssa
        dup void* <ref> &ScriptStringFree drop :> ssa
        script size>> [ 512 + ] map :> dim
        dim dc [ ssa dim { 256 256 } draw-script-string-at ] make-bitmap-image
    ] with-memory-dc ;

: reference-coverage ( image -- n )
    bitmap>> 4 <groups> [ first ] map-sum ;

: alpha-coverage ( image -- n )
    bitmap>> 4 <groups> [ last ] map-sum ;

:: preserves-ink? ( font text -- retained? expanded? )
    font text cached-script-string :> script
    script wide-reference reference-coverage
    script script-string>image :> raster
    raster alpha-coverage =
    raster dim>> script size>> = not ;

{ t t } [ "Arial" overhang-font t >>italic? "f" preserves-ink? ] unit-test
{ t t } [
    "Consolas" overhang-font
    "a\u000301\u000301\u000301\u000301\u000301\u000301\u000301\u000301"
    preserves-ink?
] unit-test

! More than one initial padding height of stacked marks forces guard growth.
{ t t } [
    "Consolas" overhang-font "a" 24 CHAR: \u000301 <string> append preserves-ink?
] unit-test

:: overhang-selection? ( -- raised? correct? )
    "Consolas" overhang-font
    "a" 24 769 <string> append 0 25 COLOR: red <selection>
    cached-script-string :> script
    script script-string>image :> image
    script origin>> second :> top
    top 0 >
    image bitmap>> 4 <groups> [ :> i
        image dim>> second 1 - i image dim>> first /i - top < [
            dup last zero? [ drop t ] [ 3 head B{ 255 255 255 } = ] if
        ] [ drop t ] if
    ] map-index [ ] all? ;

{ t t } [ overhang-selection? ] unit-test

! Raster expansion cannot change advances or hit-test coordinates.
:: unchanged-layout? ( -- size? caret? )
    "Consolas" overhang-font "a" 24 769 <string> append cached-script-string :> script
    script size>> :> size
    25 script line-offset>x :> x
    script script-string>image drop
    script size>> size = 25 script line-offset>x x = ;

{ t t } [ unchanged-layout? ] unit-test

! Opaque text retains the native GDI pixels, including italic overhang.
:: opaque-pixels? ( -- equal? order )
    "Arial" <font> 48 >>size t >>italic? "f" cached-script-string :> script
    script wide-reference :> reference
    reference 0xffffff script size>> 256 bitmap-ink-bounds :> bounds
    reference bounds crop-text-bitmap bitmap>>
    script script-string>image [ bitmap>> = ] [ component-order>> ] bi ;

{ t BGRX } [ opaque-pixels? ] unit-test

:: positioned-image? ( -- ? )
    "Consolas" overhang-font :> font
    "a" 24 769 <string> append :> text
    font text string>image nip
    font text cached-script-string origin>> scale-dim vneg = ;

{ t } [
    uniscribe-renderer font-renderer [ positioned-image? ] with-variable
] unit-test

! Zero advance does not imply empty ink: standalone marks can extend left.
{ t t } [ "Consolas" overhang-font "\u000301" preserves-ink? ] unit-test
{ t t } [ "Consolas" overhang-font "\u000338" preserves-ink? ] unit-test
