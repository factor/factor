! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.data alien.strings arrays assocs byte-arrays cache
classes.struct destructors fonts fonts.shaping init io.encodings.string
io.encodings.utf16 kernel locals math math.bitwise math.functions math.order
namespaces opengl sequences windows.com windows.directx.dwrite
windows.fonts windows.ole32 windows.types ;
FROM: alien.c-types => float ;
IN: windows.directwrite

TUPLE: directwrite-layout < disposable font string pointer metrics size image origin ;

: <directwrite-factory> ( -- factory )
    DWRITE_FACTORY_TYPE_SHARED IDWriteFactory-iid
    { void* } [ DWriteCreateFactory check-ole32-error ] with-out-parameters ;

: directwrite-scale ( -- scale ) gl-scale-factor get-global 1.0 or ;

:: directwrite-utf16-index ( string index -- units )
    0 index string subseq utf16n encode length 2 /i ;

:: directwrite-codepoint-index ( string index -- codepoints )
    0 :> units!
    string [ 0xffff > [ 2 ] [ 1 ] if units + units! units index <= ] count ;

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

:: <directwrite-layout> ( font string -- layout )
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

M: directwrite-layout dispose* pointer>> com-release ;

:: directwrite-offset>x ( index layout -- x )
    layout string>> dup selection? [ string>> ] when :> text
    layout pointer>> text index directwrite-utf16-index FALSE
    0.0 float <ref> :> x
    0.0 float <ref> :> y
    x y DWRITE_HIT_TEST_METRICS new
    IDWriteTextLayout::HitTestTextPosition check-ole32-error
    x float deref ;

:: directwrite-x>offset ( x layout -- index )
    DWRITE_HIT_TEST_METRICS new :> hit
    FALSE int <ref> :> trailing
    FALSE int <ref> :> inside
    layout pointer>> x 0.0 trailing inside hit
    IDWriteTextLayout::HitTestPoint check-ole32-error
    layout string>> dup selection? [ string>> ] when
    hit textPosition>> trailing int deref 0 = [ 0 ] [ hit length>> ] if +
    directwrite-codepoint-index ;

SYMBOL: cached-directwrite-layouts

:: cached-directwrite-layout ( font string -- layout )
    font string directwrite-scale 3array cached-directwrite-layouts get-global
    [ drop font string <directwrite-layout> ] cache ;

STARTUP-HOOK: [ <cache-assoc> cached-directwrite-layouts set-global ]

! A logical selection can cover several disjoint visual runs in bidi text.
:: directwrite-selection-rects ( layout -- rects )
    layout string>> :> selection
    selection selection? [
        selection string>> :> text
        text selection [ start>> ] [ end>> ] bi min directwrite-utf16-index :> start
        text selection [ start>> ] [ end>> ] bi max directwrite-utf16-index start - :> length
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
