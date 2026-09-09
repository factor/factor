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

TUPLE: script-string < disposable font string metrics ssa size image ;

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

:: draw-script-string ( ssa size script-string -- )
    ! Selection is composited separately; system highlight colors are never
    ! suitable for an application-provided RGBA selection background.
    script-string drop
    ssa 0 0 ETO_OPAQUE { 0 0 } size <RECT> 0 0 FALSE
    ScriptStringOut check-ole32-error ;

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
    image bitmap>> uint32_t cast-array :> pixels
    pixels [ :> index
        0xff bitand
        index columns length mod columns nth palettes nth nth
            index pixels set-nth
    ] each-index
    image RGBA >>component-order ;

:: render-image ( dc ssa script-string -- image )
    script-string size>> :> size
    size dc [ ssa size script-string draw-script-string ] make-bitmap-image
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
        dup size>> [ zero? ] any? [
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
