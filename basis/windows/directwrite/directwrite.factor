! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.data alien.strings arrays assocs byte-arrays cache
classes.struct destructors fonts fonts.shaping hashtables.identity.private init io.encodings.string
io.encodings.utf16 kernel locals math math.bitwise math.functions math.order
namespaces opengl sequences ui.text.index-maps windows.com windows.directx.dwrite
windows.directwrite.indexed windows.fonts windows.ole32 windows.types ;
FROM: alien.c-types => float ;
FROM: destructors.private => register-disposable ;
IN: windows.directwrite

TUPLE: directwrite-layout < disposable font string pointer metrics size image origin index-map selection-rects glyph-index ;

: <directwrite-factory> ( -- factory )
    DWRITE_FACTORY_TYPE_SHARED IDWriteFactory-iid
    { void* } [ DWriteCreateFactory check-ole32-error ] with-out-parameters ;

: directwrite-scale ( -- scale ) gl-scale-factor get-global 1.0 or ;

:: directwrite-utf16-index ( string index -- units )
    index string <utf16-index-map> codepoint>native ;

:: directwrite-codepoint-index ( string index -- codepoints )
    index string <utf16-index-map> native>codepoint string length min ;

:: directwrite-layout-index-map ( layout -- map )
    layout index-map>> [ ] [
        layout string>> dup selection? [ string>> ] when
        <utf16-index-map> dup layout index-map<<
    ] if* ;

: <directwrite-font-collection> ( factory -- collection )
    f void* <ref> [ FALSE IDWriteFactory::GetSystemFontCollection check-ole32-error ] keep
    void* deref ;

ERROR: missing-directwrite-fallback-font ;

:: directwrite-family ( collection name -- resolved-name index )
    collection name utf16n string>alien
    { uint int } [ IDWriteFontCollection::FindFamilyName check-ole32-error ] with-out-parameters
    0 = [
        drop
        collection "Segoe UI" utf16n string>alien
        { uint int } [ IDWriteFontCollection::FindFamilyName check-ole32-error ] with-out-parameters
        0 = [ missing-directwrite-fallback-font ] when
        "Segoe UI" swap
    ] [ name swap ] if ;

:: directwrite-family-name ( factory font -- name )
    factory <directwrite-font-collection>
    [ font name>> windows-font-name directwrite-family drop ] with-com-interface ;

:: <directwrite-format> ( factory font -- format )
    [ factory factory font directwrite-family-name utf16n string>alien
    f font bold?>> DWRITE_FONT_WEIGHT_BOLD DWRITE_FONT_WEIGHT_NORMAL ?
    font italic?>> DWRITE_FONT_STYLE_ITALIC DWRITE_FONT_STYLE_NORMAL ?
    DWRITE_FONT_STRETCH_NORMAL font size>> directwrite-scale *
    font font-locale utf16n string>alien
    { void* } [ IDWriteFactory::CreateTextFormat check-ole32-error ] with-out-parameters |com-release
    dup DWRITE_WORD_WRAPPING_NO_WRAP IDWriteTextFormat::SetWordWrapping check-ole32-error
    dup font font-text-direction right-to-left =
    DWRITE_READING_DIRECTION_RIGHT_TO_LEFT DWRITE_READING_DIRECTION_LEFT_TO_RIGHT ?
    IDWriteTextFormat::SetReadingDirection check-ole32-error
    font font-tab-width [ over swap directwrite-scale *
        IDWriteTextFormat::SetIncrementalTabStop check-ole32-error ] when* ] with-destructors ;

: directwrite-text-metrics ( pointer -- metrics )
    DWRITE_TEXT_METRICS new [ IDWriteTextLayout::GetMetrics check-ole32-error ] keep ;

:: directwrite-line-metrics ( pointer -- metrics )
    pointer directwrite-text-metrics :> text
    text lineCount>> :> count
    count DWRITE_LINE_METRICS heap-size * <byte-array> :> lines
    pointer lines count { uint } [ IDWriteTextLayout::GetLineMetrics check-ole32-error ] with-out-parameters drop
    lines DWRITE_LINE_METRICS memory>struct :> line
    metrics new
        text widthIncludingTrailingWhitespace>> >>width
        line baseline>> >>ascent
        line height>> line baseline>> - >>descent
        text height>> >>height
        0 >>leading ;

! DirectWrite stores OpenType tags little endian.
: directwrite-feature-tag ( tag -- n )
    0 [ 8 * shift bitor ] reduce-index ;

:: set-directwrite-features ( pointer factory features length -- )
    factory { void* } [ IDWriteFactory::CreateTypography check-ole32-error ] with-out-parameters
    [ :> typography
        features [| tag value |
            typography DWRITE_FONT_FEATURE new
                tag directwrite-feature-tag >>nameTag value >>parameter
            IDWriteTypography::AddFontFeature check-ole32-error
        ] assoc-each
        pointer typography DWRITE_TEXT_RANGE new 0 >>startPosition length >>length
        IDWriteTextLayout::SetTypography check-ole32-error
    ] with-com-interface ;

:: directwrite-font-metrics ( factory font -- native )
    factory <directwrite-font-collection> [ :> collection
        collection font name>> windows-font-name directwrite-family nip :> index
        collection index { void* } [ IDWriteFontCollection::GetFontFamily check-ole32-error ] with-out-parameters
        [ :> family
            family font bold?>> DWRITE_FONT_WEIGHT_BOLD DWRITE_FONT_WEIGHT_NORMAL ?
            DWRITE_FONT_STRETCH_NORMAL
            font italic?>> DWRITE_FONT_STYLE_ITALIC DWRITE_FONT_STYLE_NORMAL ?
            { void* } [ IDWriteFontFamily::GetFirstMatchingFont check-ole32-error ] with-out-parameters
            [ DWRITE_FONT_METRICS new [ IDWriteFont::GetMetrics ] keep ] with-com-interface
        ] with-com-interface
    ] with-com-interface ;

: snapshot-directwrite-font-name ( font -- copy )
    clone [ windows-font-name clone ] change-name ;

:: <plain-directwrite-layout> ( input-font string -- layout )
    input-font snapshot-directwrite-font-name :> font
    [ <directwrite-factory> [ :> factory
        factory font <directwrite-format> [ :> format
            string dup selection? [ string>> ] when :> text
            text utf16n encode :> encoded
            factory encoded encoded length 2 /i format 1000000.0 1000000.0
            { void* } [ IDWriteFactory::CreateTextLayout check-ole32-error ] with-out-parameters |com-release :> pointer
            pointer factory font font-features encoded length 2 /i set-directwrite-features
            pointer directwrite-text-metrics widthIncludingTrailingWhitespace>> 1.0 max :> width
            pointer width IDWriteTextLayout::SetMaxWidth check-ole32-error
            pointer directwrite-line-metrics :> metrics
            factory font directwrite-font-metrics :> native
            font size>> directwrite-scale * native designUnitsPerEm>> / :> scale
            metrics native capHeight>> scale * >>cap-height
                native xHeight>> scale * >>x-height drop
            pointer DWRITE_OVERHANG_METRICS new
            [ IDWriteTextLayout::GetOverhangMetrics check-ole32-error ] keep :> ink
            ink [ left>> ] [ top>> ] bi 2array [ 0 max ceiling >integer ] map :> origin
            directwrite-layout new-disposable
                font >>font string >>string pointer >>pointer metrics >>metrics
                origin >>origin
                metrics width>> origin first + ink right>> 0 max +
                metrics height>> origin second + ink bottom>> 0 max +
                2array [ ceiling >integer ] map >>size
        ] with-com-interface
    ] with-com-interface ] with-destructors ;

DEFER: cached-directwrite-layout

:: index-directwrite-layout ( layout -- layout )
    layout string>> :> text
    text length 4096 > layout font>> font-text-direction right-to-left = not and [
        text [ dup 32 >= swap 126 <= and ] all? [
            layout pointer>> <directwrite-glyph-index> :> index
            layout index >>glyph-index drop
            ! GetMetrics accumulates advances in single precision and can
            ! overestimate a ten-million-character row by millions of pixels.
            layout metrics>> index width>> >>width drop
            index width>> layout origin>> first +
            index regions>> [ right>> ] [ max ] map-reduce max ceiling >integer
            0 layout size>> set-nth
        ] when
    ] when
    layout ;

:: <directwrite-layout> ( font text -- layout )
    text selection? [
        ! Selection is paint state. Share the native shaped layout instead
        ! of rebuilding millions of glyphs whenever its endpoints change.
        font text string>> cached-directwrite-layout
        dup directwrite-layout-index-map drop clone
        dup pointer>> IUnknown::AddRef drop
        dup register-disposable
        dup glyph-index>> [ retain-glyph-index drop ] when*
        text >>string f >>image f >>selection-rects
    ] [
        [ font text <plain-directwrite-layout> |dispose index-directwrite-layout ] with-destructors
    ] if ;

M: directwrite-layout dispose*
    [ pointer>> com-release ]
    [ glyph-index>> [ release-glyph-index ] when* ]
    [ f >>pointer f >>glyph-index drop ] tri ;

:: directwrite-offset>x ( index layout -- x )
    layout check-disposed drop
    layout pointer>> index layout directwrite-layout-index-map codepoint>native FALSE
    0.0 float <ref> :> x
    0.0 float <ref> :> y
    x y DWRITE_HIT_TEST_METRICS new
    IDWriteTextLayout::HitTestTextPosition check-ole32-error
    x float deref ;

:: directwrite-x>offset ( x layout -- index )
    layout check-disposed drop
    DWRITE_HIT_TEST_METRICS new :> hit
    FALSE int <ref> :> trailing
    FALSE int <ref> :> inside
    layout pointer>> x 0.0 trailing inside hit
    IDWriteTextLayout::HitTestPoint check-ole32-error
    hit textPosition>> trailing int deref 0 = [ 0 ] [ hit length>> ] if +
    layout directwrite-layout-index-map native>codepoint ;

SYMBOL: cached-directwrite-layouts
SYMBOL: directwrite-layout-aliases
directwrite-layout-aliases [ <cache-assoc> ] initialize

! Equal output rows share one native layout, but comparing distinct 10MB
! strings on every repaint is still linear work. Remember each object's
! canonical cache key, and touch the owning cache on every alias hit.
TUPLE: directwrite-layout-alias < disposable key ;
M: directwrite-layout-alias dispose* drop ;

:: directwrite-layout-key ( font string -- key )
    font snapshot-directwrite-font-name string directwrite-scale 3array ;

:: directwrite-aliased-layout ( font string -- layout )
    font snapshot-directwrite-font-name string <identity-wrapper>
    string hashcode directwrite-scale 4array :> alias-key
    alias-key directwrite-layout-aliases get-global [
        drop font string directwrite-layout-key cached-directwrite-layouts get-global
        [ drop font string <directwrite-layout> ] cache :> layout
        directwrite-layout-alias new-disposable
            layout font>> layout string>> directwrite-layout-key >>key
    ] cache :> alias
    ! The canonical string may have been edited through another reference.
    alias key>> second hashcode string hashcode = [
        alias key>> cached-directwrite-layouts get-global
        [ first2 <directwrite-layout> ] cache
    ] [
        alias-key directwrite-layout-aliases get-global delete-at
        font string directwrite-aliased-layout
    ] if ;

:: cached-directwrite-layout ( font string -- layout )
    string dup selection? [ string>> ] when length 4096 > [
        font string directwrite-aliased-layout
    ] [
        font string directwrite-layout-key cached-directwrite-layouts get-global
        [ drop font string <directwrite-layout> ] cache
    ] if ;

STARTUP-HOOK: [
    <cache-assoc> cached-directwrite-layouts set-global
    <cache-assoc> directwrite-layout-aliases set-global
]

! A logical selection can cover several disjoint visual runs in bidi text.
:: (directwrite-selection-rects) ( layout -- rects )
    layout check-disposed drop
    layout string>> :> selection
    selection selection? [
        layout directwrite-layout-index-map :> map
        selection [ start>> ] [ end>> ] bi min map codepoint>native :> start
        selection [ start>> ] [ end>> ] bi max map codepoint>native start - :> length
        0 uint <ref> :> count
        layout pointer>> start length 0.0 0.0 f 0 count
        IDWriteTextLayout::HitTestTextRange drop
        count uint deref :> n
        n DWRITE_HIT_TEST_METRICS heap-size * <byte-array> :> buffer
        layout pointer>> start length 0.0 0.0 buffer n count
        IDWriteTextLayout::HitTestTextRange check-ole32-error
        n [ DWRITE_HIT_TEST_METRICS heap-size * buffer <displaced-alien>
            DWRITE_HIT_TEST_METRICS memory>struct ] map-integers
    ] [ { } ] if ;

:: directwrite-selection-rects ( layout -- rects )
    layout check-disposed drop
    layout selection-rects>> [ ] [
        layout (directwrite-selection-rects) dup layout selection-rects<<
    ] if* ;
