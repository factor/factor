! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.

USING: accessors alien.c-types alien.data arrays assocs
byte-arrays cache classes.struct colors combinators destructors
fonts generalizations images init io.encodings.string io.encodings.utf16 kernel
literals locals math math.bitwise math.functions math.order namespaces
opengl sequences sequences.generalizations specialized-arrays windows.errors windows.fonts
windows.gdi32 windows.offscreen windows.ole32 windows.types
windows.usp10 ;

SPECIALIZED-ARRAY: uint32_t
IN: windows.uniscribe

! Size and metrics remain logical; origin locates (0,0) inside the ink bitmap.
TUPLE: script-string < disposable font string metrics ssa size image origin ;

<PRIVATE

CONSTANT: ssa-dwFlags flags{ SSA_GLYPHS SSA_FALLBACK SSA_TAB }

: uniscribe-text ( string/selection -- string )
    dup selection? [ string>> ] when ;

:: >codepoint-index ( str utf16-index -- codepoint-index )
    ! A native index can split a surrogate pair; keep it at the leading edge.
    0 :> units!
    str [
        0xffff > [ 2 ] [ 1 ] if units + units!
        units utf16-index <=
    ] count ;

:: >utf16-index ( str codepoint-index -- utf16-index )
    0 codepoint-index str subseq utf16n encode length 2 /i ;

PRIVATE>

:: line-offset>x ( n script-string -- x )
    script-string string>> uniscribe-text :> text
    text empty? [ 0 ] [
        text n >utf16-index :> n-utf16
        script-string ssa>>
        n text length = [ n-utf16 1 - TRUE ] [ n-utf16 FALSE ] if
        { int } [ ScriptStringCPtoX check-ole32-error ] with-out-parameters
    ] if ;

:: x>line-offset ( x script-string -- n trailing )
    script-string string>> uniscribe-text :> str
    str empty? [ 0 0 ] [
        script-string ssa>> x
        { int int } [ ScriptStringXtoCP check-ole32-error ] with-out-parameters
        :> trailing :> n
        ! Native trailing is a UTF-16 cluster length, not a boolean.
        n 0 < [ n trailing ] [
            str n >codepoint-index :> start
            start str n trailing + >codepoint-index start -
        ] if
    ] if ;

<PRIVATE

: make-ssa ( dc script-string -- ssa )
    uniscribe-text
    utf16n encode ! pString
    dup length 2 /i ! cString
    dup 1.5 * 16 + >integer ! cGlyphs -- MSDN says this is "recommended size"
    -1 ! iCharset -- Unicode
    ssa-dwFlags
    0 ! iReqWidth
    f ! psControl
    f ! psState
    f ! piDx
    f ! pTabdef
    f ! pbInClass
    f void* <ref> ! pssa
    [ ScriptStringAnalyse ] keep
    [ check-ole32-error ] [ |ScriptStringFree void* deref ] bi* ;

:: opaque-text-color ( font -- color )
    font foreground>> >rgba-components :> alpha 3array
    font background>> >rgba-components drop 3array
    [ [ alpha * ] [ 1 alpha - * ] bi* + ] 2map
    first3 1 <rgba> ;

: set-dc-colors ( dc font -- )
    dup background>> >rgba alpha>> 1 number= [
        ! Composite translucent text against the opaque background before
        ! GDI applies glyph coverage, retaining its native antialiasing.
        [ background>> color>RGB SetBkColor drop ]
        [ opaque-text-color color>RGB SetTextColor drop ] 2bi
    ] [
        ! Draw white text on black background. The resulting grayscale
        ! image will be used as transparency mask for the actual color.
        drop
        [ COLOR: black color>RGB SetBkColor drop ]
        [ COLOR: white color>RGB SetTextColor drop ] bi
    ] if ;

: selection-start/end ( script-string -- iMinSel iMaxSel )
    string>> dup selection? [ [ start>> ] [ end>> ] bi ] [ drop 0 0 ] if ;

:: draw-script-string-at ( ssa size origin -- )
    ssa origin first2 ETO_OPAQUE { 0 0 } size <RECT> 0 0 FALSE
    ScriptStringOut check-ole32-error ;

:: bitmap-ink-bounds ( image background logical-size padding -- bounds )
    image dim>> first2 :> height :> width
    padding :> left! padding :> top!
    logical-size first padding + :> right!
    logical-size second padding + :> bottom!
    image bitmap>> uint32_t cast-array [ :> index
        0xffffff bitand background = not [
            index width mod :> x
            height 1 - index width /i - :> y
            left x min left! top y min top!
            right x 1 + max right! bottom y 1 + max bottom!
        ] when
    ] each-index
    left top right bottom 4array ;

:: crop-text-bitmap ( image bounds -- image' )
    bounds first4 :> bottom :> right :> top :> left
    right left - :> width bottom top - :> height
    image dim>> first :> source-width
    image dim>> second bottom - :> source-row
    image bitmap>> uint32_t cast-array :> source
    width height * 4 * <byte-array> :> bytes
    bytes uint32_t cast-array :> target
    target [ :> index drop
        index width /i source-row + source-width *
        index width mod left + + source nth
        index target set-nth
    ] each-index
    image clone bytes >>bitmap width height 2array >>dim ;

:: padded-text-bitmap ( dc ssa script padding -- image origin )
    script size>> :> logical-size
    logical-size [ padding 2 * + ] map :> dim
    ! COLORREF and DIB pixels have opposite red/blue ordering.
    dc 0 SetBkColor :> native-background
    dc native-background SetBkColor drop
    native-background 0xff bitand 16 shift
    native-background 0xff00 bitand bitor
    native-background -16 shift 0xff bitand bitor :> background
    dim dc [ ssa dim padding dup 2array draw-script-string-at ] make-bitmap-image :> image
    image background logical-size padding bitmap-ink-bounds :> bounds
    ! Keep a generous clear guard, expanding for stacked marks instead of
    ! assuming a fixed overhang limit. The final crop also retains whitespace.
    padding 2 /i :> guard
    bounds first guard < bounds second guard < or
    bounds third dim first guard - > or
    bounds fourth dim second guard - > or [
        dc ssa script padding 2 * padded-text-bitmap
    ] [
        image bounds crop-text-bitmap
        padding bounds first - padding bounds second - 2array
    ] if ;

:: draw-script-string ( ssa size script-string -- )
    script-string drop ssa size { 0 0 } draw-script-string-at ;

! The image is a grayscale rendering of a text string. We want the text to
! have the given color. Move the blue channel of the image (any color
! channel will do, since it's grayscale) into its alpha channel, and make
! the entire image a rectangle of the given color with varying
! transparency.
:: color-to-alpha ( image color -- image' )
    color >rgba-components :> alpha
    [ 255 * round >integer ] tri@
    16 shift swap 8 shift bitor bitor :> rgb
    image bitmap>> uint32_t cast-array
        alpha 1 <
        [ [ 0xff bitand alpha * >integer 24 shift rgb bitor ] map! ]
        [ [ 0xff bitand                  24 shift rgb bitor ] map! ]
        if drop
    image RGBA >>component-order ;

:: over-rgba ( foreground background coverage -- rgba )
    foreground >rgba-components coverage * :> fa :> fb :> fg :> fr
    background >rgba-components :> ba :> bb :> bg :> br
    ba 1 fa - * :> remaining
    fa remaining + :> alpha
    alpha zero? [ 0 0 0 0 <rgba> ] [
        fr fa * br remaining * + alpha /
        fg fa * bg remaining * + alpha /
        fb fa * bb remaining * + alpha /
        alpha <rgba>
    ] if ;

: packed-rgba ( color -- pixel )
    >rgba-components [ 255 * round >integer ] 4 napply
    24 shift swap 16 shift bitor swap 8 shift bitor bitor ;

:: selection-columns ( script-string -- columns )
    script-string size>> first <byte-array> :> columns
    script-string string>> :> selection
    selection selection? [
        selection start>> selection end>> [ min ] [ max ] 2bi
        :> end :> start
        ! Convert the prefix once, then advance by each codepoint's UTF-16
        ! length. Re-encoding every prefix made long selections quadratic.
        selection string>> :> str
        str start >utf16-index :> utf16!
        start end str subseq [ :> ch
            script-string ssa>> utf16 FALSE { int }
            [ ScriptStringCPtoX check-ole32-error ] with-out-parameters
            script-string ssa>> utf16 TRUE { int }
            [ ScriptStringCPtoX check-ole32-error ] with-out-parameters
            [ min ] [ max ] 2bi :> right :> left
            right columns length min left 0 max - 0 max <iota> [
                left 0 max + 1 swap columns set-nth
            ] each
            utf16 ch 0xffff > [ 2 ] [ 1 ] if + utf16!
        ] each
    ] when columns ;

:: composite-text-image ( image script-string -- image )
    script-string font>> :> font
    font background>> :> background
    script-string string>> dup selection?
    [ color>> background 1 over-rgba ] [ drop background ] if :> selected
    background selected 2array [ :> bg
        256 <iota> [ 255 / font foreground>> bg rot over-rgba packed-rgba ] map
    ] map :> palettes
    script-string selection-columns :> columns
    script-string origin>> { 0 0 } or :> origin
    image dim>> script-string size>> or first2 :> height :> width
    image bitmap>> uint32_t cast-array :> pixels
    pixels [ :> index
        0xff bitand :> coverage
        index width mod origin first - :> x
        height 1 - index width /i - origin second - :> y
        x 0 >= x columns length < and
        y 0 >= y script-string size>> second < and and
        [ x columns nth ] [ 0 ] if palettes nth
        coverage swap nth index pixels set-nth
    ] each-index
    image RGBA >>component-order ;

:: render-image ( dc ssa script-string -- image )
    dc ssa script-string script-string size>> second 16 max
    padded-text-bitmap script-string swap >>origin drop
    script-string font>> background>> >rgba alpha>> 1 number=
    script-string string>> selection? not and
    [ ] [ script-string composite-text-image ] if ;

: set-dc-font ( dc font -- )
    cache-font SelectObject win32-error=0/f ;

:: configure-script-dc ( script dc -- )
    ! A single coverage channel is only valid with grayscale smoothing.
    ! Set quality before analysis so Uniscribe fallback fonts inherit it.
    script string>> selection?
    script font>> background>> >rgba alpha>> 1 number= not or
    ANTIALIASED_QUALITY DEFAULT_QUALITY ? :> quality
    dc script font>> quality cache-font-with-quality
    SelectObject win32-error=0/f
    script string>> selection? [
        dc COLOR: black color>RGB SetBkColor drop
        dc COLOR: white color>RGB SetTextColor drop
    ] [ dc script font>> set-dc-colors ] if ;
: ssa-size ( ssa -- dim )
    ScriptString_pSize
    dup win32-error=0/f
    [ cx>> ] [ cy>> ] bi 2array ;

:: dc-metrics ( dc -- metrics )
    dc TEXTMETRICW new
    [ GetTextMetrics win32-error=0/f ] keep
    TEXTMETRIC>metrics
    dc CHAR: H dc-glyph-height >>cap-height
    dc CHAR: x dc-glyph-height >>x-height ;

! DC limit is default soft-limited to 10,000 per process.
:: <script-string> ( font string -- script-string )
    [ :> dc
        dc font set-dc-font
        dc dc-metrics :> metrics
        ! ScriptStringAnalyse requires at least one UTF-16 character.
        string uniscribe-text empty? [
            f 0 metrics height>> 2array
        ] [ dc string make-ssa dup ssa-size ] if :> size :> ssa
        ! Register ownership only after all fallible native setup succeeds.
        script-string new-disposable font >>font string >>string
            metrics size first >>width >>metrics ssa >>ssa size >>size
    ] with-memory-dc ;

PRIVATE>

M: script-string dispose*
    ssa>> [ void* <ref> ScriptStringFree check-ole32-error ] when* ;

SYMBOL: cached-script-strings

:: cached-script-string ( font string -- script-string )
    ! A layout owns native glyph metrics and pixels at its backing scale.
    font string gl-scale-factor get-global 1.0 or 3array
    cached-script-strings get-global
    [ drop font string <script-string> ] cache ;

: script-string>image ( script-string -- image )
    dup image>> [
        ! Nonempty zero-advance strings can still contain visible marks.
        dup ssa>> not [
            dup size>> <image> swap >>dim B{ } >>bitmap
                RGBA >>component-order ubyte-components >>component-type
                t >>upside-down? >>image
        ] [ [
            {
                [ 2dup configure-script-dc drop ]
                [
                    dup pick string>> make-ssa
                    dup void* <ref> &ScriptStringFree drop
                    pick render-image >>image
                ]
            } cleave
        ] with-memory-dc ] if
    ] unless image>> ;

STARTUP-HOOK: [ <cache-assoc> cached-script-strings set-global ]
