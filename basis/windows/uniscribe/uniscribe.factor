! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.

USING: accessors alien.c-types alien.data arrays assocs
byte-arrays cache classes.struct colors combinators destructors
fonts fonts.shaping generalizations images init io.encodings.string io.encodings.utf16 kernel
libc literals locals math math.bitwise math.functions math.order namespaces
opengl sequences sequences.generalizations sets specialized-arrays strings windows.errors windows.fonts
windows.gdi32 windows.offscreen windows.ole32 windows.types
windows.usp10 ;

SPECIALIZED-ARRAY: uint32_t
SPECIALIZED-ARRAY: ushort
IN: windows.uniscribe

! Size/metrics are backing-pixel layout bounds; origin locates (0,0) in the bitmap.
TUPLE: script-string < disposable font string metrics ssa size image origin backing-scale utf16-boundaries ;

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

:: codepoint-boundaries ( str -- boundaries )
    str length 1 + 0 <array> :> boundaries
    0 :> units!
    str [ :> i
        0xffff > [ 2 ] [ 1 ] if units + units!
        units i 1 + boundaries set-nth
    ] each-index
    boundaries ;

:: boundary>codepoint ( boundaries utf16-index -- codepoint-index )
    ! Upper bound minus one floors hits inside a surrogate pair. It also
    ! preserves the old conversion's behavior outside either end of the text.
    0 :> low! boundaries length :> high!
    [ low high < ] [
        low high + 2 /i :> middle
        middle boundaries nth utf16-index <=
        [ middle 1 + low! ] [ middle high! ] if
    ] while
    low 1 - 0 max ;

PRIVATE>

:: line-offset>x ( n script-string -- x )
    script-string check-disposed drop
    script-string string>> uniscribe-text :> text
    text empty? [ 0 ] [
        n script-string utf16-boundaries>> nth :> n-utf16
        script-string ssa>>
        n text length = [ n-utf16 1 - TRUE ] [ n-utf16 FALSE ] if
        { int } [ ScriptStringCPtoX check-ole32-error ] with-out-parameters
    ] if ;

:: x>line-offset ( x script-string -- n trailing )
    script-string check-disposed drop
    script-string string>> uniscribe-text :> str
    str empty? [ 0 0 ] [
        script-string ssa>> x
        { int int } [ ScriptStringXtoCP check-ole32-error ] with-out-parameters
        :> trailing :> n
        ! Native trailing is a UTF-16 cluster length, not a boolean.
        n 0 < [ n trailing ] [
            script-string utf16-boundaries>> :> boundaries
            boundaries n boundary>codepoint :> start
            start boundaries n trailing + boundary>codepoint start -
        ] if
    ] if ;

<PRIVATE

:: uniscribe-tabdef ( width/f scale -- tabdef/f )
    width/f [
        width/f scale * round 1 max :> pixels
        pixels 0x7fffffff > [ width/f invalid-tab-width ] when
        pixels >integer int <ref> malloc-byte-array &free :> interval
        SCRIPT_TABDEF new
            1 >>cTabStops 4 >>iScale interval >>pTabStops 0 >>iTabOrigin
    ] [ f ] if ;

:: selected-font-covers-ascii? ( dc text -- ? )
    ! Check only distinct characters, keeping the native query small even
    ! when the paragraph contains tens of thousands of characters.
    text members >string :> chars
    chars length ushort <c-array> :> glyphs
    dc chars utf16n encode chars length glyphs GGI_MARK_NONEXISTING_GLYPHS
    GetGlyphIndicesW GDI_ERROR = [ f ] [ glyphs [ 0xffff = not ] all? ] if ;

:: uniscribe-long-line-flags ( dc text flags -- flags' )
    ! Native fallback can replace a fully supported font near 32K ASCII
    ! characters. This conservative trigger is not an input-size limit.
    ! Bypass fallback only when the selected font covers every glyph.
    text length 32000 >= [
        text [ dup 0x20 >= swap 0x7e <= and ] all? [
            dc text selected-font-covers-ascii?
            [ flags SSA_FALLBACK bitnot bitand ] [ flags ] if
        ] [ flags ] if
    ] [ flags ] if ;

: uniscribe-glyph-capacity ( utf16-length -- capacity )
    ! ScriptStringAnalyse rejects a glyph capacity above the WORD range.
    1.5 * 16 + >integer 65535 min ;

:: (make-ssa) ( dc string flags tabdef -- ssa )
    string uniscribe-text :> text
    dc text utf16n encode
    dup length 2 /i ! cString
    dup uniscribe-glyph-capacity
    -1 dc text flags uniscribe-long-line-flags 0 f f f tabdef f
    f void* <ref>
    [ ScriptStringAnalyse ] keep
    [ check-ole32-error ] [ |ScriptStringFree void* deref ] bi* ;

! Successful analyses belong to the caller. Layout construction registers
! error-only cleanup; temporary rendering registers unconditional cleanup.
: make-ssa ( dc string -- ssa )
    [ ssa-dwFlags f (make-ssa) ] with-destructors ;

:: make-ssa-with-font ( dc string font scale -- ssa )
    ! Tab-stop storage must remain fixed while native analysis uses it.
    [
        font font-tab-width scale uniscribe-tabdef :> tabdef
        ssa-dwFlags font font-text-direction right-to-left =
        [ SSA_RTL bitor ] when :> flags
        dc string flags tabdef (make-ssa)
    ] with-destructors ;

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
    script-string check-disposed drop
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
    dc script font>> quality script backing-scale>> cache-font-at-scale
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

! Layouts and hash keys must not retain caller-owned mutable inputs.
: snapshot-color ( color/f -- rgba/f )
    dup [ >rgba ] when ;

:: snapshot-shaping-options ( options -- copy )
    options [ :> value :> key
        key clone
        key "features" = [
            value [ [ clone ] dip ] H{ } assoc-map-as
        ] [ value clone ] if
    ] H{ } assoc-map-as ;

: snapshot-font ( font -- copy )
    clone [ clone ] change-name
    [ snapshot-color ] change-foreground
    [ snapshot-color ] change-background
    dup shaped-font? [ [ snapshot-shaping-options ] change-shaping-options ] when ;

: snapshot-text ( string/selection -- copy )
    clone dup selection? [
        [ clone ] change-string [ snapshot-color ] change-color
    ] when ;

! DC limit is default soft-limited to 10,000 per process.
:: <script-string> ( input-font input-string -- script-string )
    input-font snapshot-font :> font
    input-string snapshot-text :> string
    string uniscribe-text codepoint-boundaries :> boundaries
    gl-scale-factor get-global 1.0 or :> scale
    [ :> dc
        dc font DEFAULT_QUALITY scale cache-font-at-scale SelectObject win32-error=0/f
        dc dc-metrics :> metrics
        ! ScriptStringAnalyse requires at least one UTF-16 character.
        string uniscribe-text empty? [
            f 0 metrics height>> 2array
        ] [
            dc string font scale make-ssa-with-font
            dup void* <ref> |ScriptStringFree drop
            dup ssa-size
        ] if :> size :> ssa
        ! Register ownership only after all fallible native setup succeeds.
        script-string new-disposable font >>font string >>string
            metrics size first >>width >>metrics ssa >>ssa size >>size
            scale >>backing-scale boundaries >>utf16-boundaries
    ] with-memory-dc ;

PRIVATE>

M: script-string dispose*
    [ ssa>> [ void* <ref> ScriptStringFree check-ole32-error ] when* ]
    [ f >>ssa drop ] bi ;

SYMBOL: cached-script-strings

:: cached-script-string ( font string -- script-string )
    ! A layout owns native glyph metrics and pixels at its backing scale.
    ! Keep key snapshots independent from the layout's own snapshots.
    font snapshot-font string snapshot-text
    gl-scale-factor get-global 1.0 or 3array :> key
    cached-script-strings get-global :> entries
    key entries [ drop font string <script-string> ] cache
    dup disposed>> [
        drop key entries delete-at
        font string cached-script-string
    ] when ;

: script-string>image ( script-string -- image )
    check-disposed
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
                    dup pick [ string>> ] [ font>> ] [ backing-scale>> ] tri make-ssa-with-font
                    dup void* <ref> &ScriptStringFree drop
                    pick render-image >>image
                ]
            } cleave
        ] with-memory-dc ] if
    ] unless image>> ;

STARTUP-HOOK: [ <cache-assoc> cached-script-strings set-global ]
