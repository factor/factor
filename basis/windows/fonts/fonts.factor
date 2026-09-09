USING: assocs memoize locals kernel accessors init fonts math
combinators opengl system-info.windows windows.errors
windows.types windows.gdi32 namespaces ;
IN: windows.fonts

MEMO: windows-fonts ( -- fonts )
    windows-major 6 >=
    H{
        { "sans-serif" "Segoe UI" }
        { "serif" "Cambria" }
        { "monospace" "Consolas" }
    }
    H{
        { "sans-serif" "Tahoma" }
        { "serif" "Times New Roman" }
        { "monospace" "Courier New" }
    } ? ;

: windows-font-name ( string -- string' )
    windows-fonts ?at drop ;

MEMO:: (cache-font-with-quality) ( name size bold? italic? quality -- HFONT )
    size neg ! nHeight
    0 0 0 ! nWidth, nEscapement, nOrientation
    bold? FW_BOLD FW_NORMAL ? ! fnWeight
    italic? TRUE FALSE ? ! fdwItalic
    FALSE ! fdwUnderline
    FALSE ! fdWStrikeOut
    DEFAULT_CHARSET ! fdwCharSet
    OUT_OUTLINE_PRECIS ! fdwOutputPrecision
    CLIP_DEFAULT_PRECIS ! fdwClipPrecision
    quality ! fdwQuality
    DEFAULT_PITCH ! fdwPitchAndFamily
    name windows-font-name
    CreateFont
    dup win32-error=0/f ;

: (cache-font) ( name size bold? italic? -- HFONT )
    DEFAULT_QUALITY (cache-font-with-quality) ;

: cache-font-with-quality ( font quality -- HFONT )
    [ {
        [ name>> ]
        [ size>> gl-scale-factor get-global [ * ] when* ]
        [ bold?>> ]
        [ italic?>> ]
    } cleave ] dip (cache-font-with-quality) ;

: cache-font ( font -- HFONT )
    DEFAULT_QUALITY cache-font-with-quality ;
STARTUP-HOOK: [
    \ (cache-font-with-quality) reset-memoized
    \ windows-fonts reset-memoized
]

: TEXTMETRIC>metrics ( TEXTMETRIC -- metrics )
    [ metrics new 0 >>width ] dip {
        [ tmHeight>> >>height ]
        [ tmAscent>> >>ascent ]
        [ tmDescent>> >>descent ]
        [ tmExternalLeading>> >>leading ]
    } cleave ;

: identity-mat2 ( -- matrix )
    MAT2 new
    dup eM11>> 1 >>value drop
    dup eM22>> 1 >>value drop ;

:: dc-glyph-height ( dc char -- height/f )
    GLYPHMETRICS new :> metrics
    dc char GGO_METRICS metrics 0 f identity-mat2 GetGlyphOutline
    GDI_ERROR = [ f ] [ metrics gmBlackBoxY>> ] if ;
