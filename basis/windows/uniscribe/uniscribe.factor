! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.

USING: accessors alien.c-types alien.data arrays assocs
byte-arrays cache classes.struct colors combinators destructors
fonts images init io.encodings.string io.encodings.utf16 kernel
literals locals math math.bitwise math.functions namespaces
opengl sequences specialized-arrays windows.errors windows.fonts
windows.gdi32 windows.offscreen windows.ole32 windows.types
windows.usp10 ;

SPECIALIZED-ARRAY: uint32_t
IN: windows.uniscribe

TUPLE: script-string < disposable font string metrics ssa size image ;

<PRIVATE

CONSTANT: ssa-dwFlags flags{ SSA_GLYPHS SSA_FALLBACK SSA_TAB }

:: >codepoint-index ( str utf16-index -- codepoint-index )
    0 utf16-index 2 * str utf16n encode subseq utf16n decode length ;

:: >utf16-index ( str codepoint-index -- utf16-index )
    0 codepoint-index str subseq utf16n encode length 2 /i ;

PRIVATE>

:: line-offset>x ( n script-string -- x )
    script-string string>> n >utf16-index :> n-utf16
    script-string ssa>> ! ssa
    n script-string string>> length = [
        n-utf16 1 - ! icp
        TRUE ! fTrailing
    ] [
        n-utf16 ! icp
        FALSE ! fTrailing
    ] if
    { int } [ ScriptStringCPtoX check-ole32-error ] with-out-parameters ;

:: x>line-offset ( x script-string -- n trailing )
    script-string ssa>> ! ssa
    x ! iX
    { int int } [ ScriptStringXtoCP check-ole32-error ] with-out-parameters
    swap dup 0 < [ script-string string>> swap >codepoint-index ] unless
    swap ;

<PRIVATE

: make-ssa ( dc script-string -- ssa )
    dup selection? [ string>> ] when
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

: set-dc-colors ( dc font -- )
    dup background>> >rgba alpha>> 1 number= [
        ! No transparency needed, set colors from the font.
        [ background>> color>RGB SetBkColor drop ]
        [ foreground>> color>RGB SetTextColor drop ] 2bi
    ] [
        ! Draw white text on black background. The resulting grayscale
        ! image will be used as transparency mask for the actual color.
        drop
        [ COLOR: black color>RGB SetBkColor drop ]
        [ COLOR: white color>RGB SetTextColor drop ] bi
    ] if ;

: selection-start/end ( script-string -- iMinSel iMaxSel )
    string>> dup selection? [ [ start>> ] [ end>> ] bi ] [ drop 0 0 ] if ;

: draw-script-string ( ssa size script-string -- )
    [
        0 ! iX
        0 ! iY
        ETO_OPAQUE ! uOptions
    ]
    [ [ { 0 0 } ] dip <RECT> ]
    [
        [let :> str str selection-start/end
            [
                str string>> dup selection? [ string>> ] when
                swap >utf16-index
            ] bi@
        ]
    ] tri*
    ! iMinSel
    ! iMaxSel
    FALSE ! fDisabled
    ScriptStringOut check-ole32-error ;

! The image is a grayscale rendering of a text string. We want the text to
! have the given color. Move the blue channel of the image (any color
! channel will do, since it's grayscale) into its alpha channel, and make
! the entire image a rectangle of the given color with varying
! transparency.
:: color-to-alpha ( image color -- image' )
    color >rgba-components :> alpha
    [ 255 * round >integer ] tri@ 3byte-array uint32_t deref 24 bits :> rgb
    image bitmap>> uint32_t cast-array
        alpha 1 <
        [ [ 0xff bitand alpha * >integer 24 shift rgb bitor ] map! ]
        [ [ 0xff bitand                  24 shift rgb bitor ] map! ]
        if drop
    image RGBA >>component-order ;

:: render-image ( dc ssa script-string -- image )
    script-string size>> :> size
    size dc [ ssa size script-string draw-script-string ] make-bitmap-image
    script-string font>> [ foreground>> ] [ background>> ] bi
    >rgba alpha>> 1 number= [ drop ] [ color-to-alpha ] if ;

: set-dc-font ( dc font -- )
    cache-font SelectObject win32-error=0/f ;

: ssa-size ( ssa -- dim )
    ScriptString_pSize
    dup win32-error=0/f
    [ cx>> ] [ cy>> ] bi 2array ;

: dc-metrics ( dc -- metrics )
    TEXTMETRICW new
    [ GetTextMetrics drop ] keep
    TEXTMETRIC>metrics ;

! DC limit is default soft-limited to 10,000 per process.
: <script-string> ( font string -- script-string )
    [ script-string new-disposable ] 2dip
        [ >>font ] [ >>string ] bi*
    [
        {
            [ over font>> set-dc-font ]
            [ dc-metrics >>metrics ]
            [ over string>> make-ssa [ >>ssa ] [ ssa-size >>size ] bi ]
        } cleave
    ] with-memory-dc ;

PRIVATE>

M: script-string dispose*
    ssa>> void* <ref> ScriptStringFree check-ole32-error ;

SYMBOL: cached-script-strings

: cached-script-string ( font string -- script-string )
    cached-script-strings get-global [ <script-string> ] 2cache ;

: script-string>image ( script-string -- image )
    dup image>> [
        [
            {
                [ over font>> [ set-dc-font ] [ set-dc-colors ] 2bi ]
                [
                    dup pick string>> make-ssa
                    dup void* <ref> &ScriptStringFree drop
                    pick render-image >>image
                ]
            } cleave
        ] with-memory-dc
    ] unless image>> ;

STARTUP-HOOK: [ <cache-assoc> cached-script-strings set-global ]
