USING: assocs memoize locals kernel accessors init fonts math
combinators windows.errors windows.types windows.gdi32 ;
IN: windows.fonts

: windows-font-name ( string -- string' )
    H{
        { "sans-serif" "Tahoma" }
        { "serif" "Times New Roman" }
        { "monospace" "Courier New" }
    } at-default ;
    
MEMO:: (cache-font) ( font -- HFONT )
    font size>> neg ! nHeight
    0 0 0 ! nWidth, nEscapement, nOrientation
    font bold?>> FW_BOLD FW_NORMAL ? ! fnWeight
    font italic?>> TRUE FALSE ? ! fdwItalic
    FALSE ! fdwUnderline
    FALSE ! fdWStrikeOut
    DEFAULT_CHARSET ! fdwCharSet
    OUT_OUTLINE_PRECIS ! fdwOutputPrecision
    CLIP_DEFAULT_PRECIS ! fdwClipPrecision
    DEFAULT_QUALITY ! fdwQuality
    DEFAULT_PITCH ! fdwPitchAndFamily
    font name>> windows-font-name
    CreateFont
    dup win32-error=0/f ;

: cache-font ( font -- HFONT ) strip-font-colors (cache-font) ;

[ \ (cache-font) reset-memoized ] "windows.fonts" add-init-hook

: TEXTMETRIC>metrics ( TEXTMETRIC -- metrics )
    [ metrics new 0 >>width ] dip {
        [ TEXTMETRICW-tmHeight >>height ]
        [ TEXTMETRICW-tmAscent >>ascent ]
        [ TEXTMETRICW-tmDescent >>descent ]
    } cleave ;
