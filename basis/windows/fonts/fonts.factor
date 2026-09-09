USING: assocs memoize locals kernel accessors init fonts math math.order
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

MEMO:: (cached-gdi-font) ( name size bold? italic? quality -- HFONT )
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
    name
    CreateFont
    dup win32-error=0/f ;

:: (cache-font-with-quality) ( name size bold? italic? quality -- HFONT )
    ! GDI accepts integer heights. Normalize before memoization so equivalent
    ! fractional sizes share a handle; positive subpixel sizes must not become
    ! zero, which asks GDI to substitute its default font height.
    ! Resolve aliases and own the name stored in the memo table.
    name windows-font-name clone size dup 0 > [ >integer 1 max ] [ >integer ] if
    bold? italic? quality (cached-gdi-font) ;

: (cache-font) ( name size bold? italic? -- HFONT )
    DEFAULT_QUALITY (cache-font-with-quality) ;

:: cache-font-at-scale ( font quality scale -- HFONT )
    font name>> font size>> scale *
    font bold?>> font italic?>> quality (cache-font-with-quality) ;

: cache-font-with-quality ( font quality -- HFONT )
    gl-scale-factor get-global 1.0 or cache-font-at-scale ;

: cache-font ( font -- HFONT )
    DEFAULT_QUALITY cache-font-with-quality ;
STARTUP-HOOK: [
    \ (cached-gdi-font) reset-memoized
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
