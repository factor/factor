! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel assocs math sequences fry io.encodings.string
io.encodings.utf16n accessors arrays combinators destructors
cache namespaces init fonts alien.c-types windows.usp10
windows.offscreen windows.gdi32 windows.ole32 windows.types
windows.fonts opengl.textures locals windows.errors ;
IN: windows.uniscribe

TUPLE: script-string font string metrics ssa size image disposed ;

: line-offset>x ( n script-string -- x )
    2dup string>> length = [
        ssa>> ! ssa
        swap 1- ! icp
        TRUE ! fTrailing
    ] [
        ssa>>
        swap ! icp
        FALSE ! fTrailing
    ] if
    0 <int> [ ScriptStringCPtoX ole32-error ] keep *int ;

: x>line-offset ( x script-string -- n trailing )
    ssa>> ! ssa
    swap ! iX
    0 <int> ! pCh
    0 <int> ! piTrailing
    [ ScriptStringXtoCP ole32-error ] 2keep [ *int ] bi@ ;

<PRIVATE

: make-script-string ( dc string -- script-string )
    dup selection? [ string>> ] when
    [ utf16n encode ] ! pString
    [ length ] bi ! cString
    dup 1.5 * 16 + >integer ! cGlyphs -- MSDN says this is "recommended size"
    -1 ! iCharset -- Unicode
    SSA_GLYPHS ! dwFlags
    0 ! iReqWidth
    f ! psControl
    f ! psState
    f ! piDx
    f ! pTabdef
    f ! pbInClass
    f <void*> ! pssa
    [ ScriptStringAnalyse ] keep
    [ ole32-error ] [ |ScriptStringFree *void* ] bi* ;

: set-dc-colors ( dc font -- )
    [ background>> color>RGB SetBkColor drop ]
    [ foreground>> color>RGB SetTextColor drop ] 2bi ;

: selection-start/end ( script-string -- iMinSel iMaxSel )
    string>> dup selection? [ [ start>> ] [ end>> ] bi ] [ drop 0 0 ] if ;

: (draw-script-string) ( script-string -- )
    [
        ssa>> ! ssa
        0 ! iX
        0 ! iY
        ETO_OPAQUE ! uOptions
    ]
    [ [ { 0 0 } ] dip size>> <RECT> ]
    [ selection-start/end ] tri
    ! iMinSel
    ! iMaxSel
    FALSE ! fDisabled
    ScriptStringOut ole32-error ;

: draw-script-string ( dc script-string -- )
    [ font>> set-dc-colors ] keep (draw-script-string) ;

:: make-script-string-image ( dc script-string -- image )
    script-string size>> dc
    [ dc script-string draw-script-string ] make-bitmap-image ;

: set-dc-font ( dc font -- )
    cache-font SelectObject win32-error=0/f ;

: script-string-size ( script-string -- dim )
    ssa>> ScriptString_pSize
    dup win32-error=0/f
    [ SIZE-cx ] [ SIZE-cy ] bi 2array ;

: dc-metrics ( dc -- metrics )
    "TEXTMETRICW" <c-object>
    [ GetTextMetrics drop ] keep
    TEXTMETRIC>metrics ;

: <script-string> ( font string -- script-string )
    [ script-string new ] 2dip
        [ >>font ] [ >>string ] bi*
    [
        {
            [ over font>> set-dc-font ]
            [ dc-metrics >>metrics ]
            [ over string>> make-script-string >>ssa ]
            [ drop dup script-string-size >>size ]
            [ over make-script-string-image >>image ]
        } cleave
    ] with-memory-dc ;

PRIVATE>

M: script-string dispose*
    ssa>> <void*> ScriptStringFree ole32-error ;

SYMBOL: cached-script-strings

: cached-script-string ( font string -- script-string )
    cached-script-strings get-global [ <script-string> ] 2cache ;

[ <cache-assoc> cached-script-strings set-global ]
"windows.uniscribe" add-init-hook
