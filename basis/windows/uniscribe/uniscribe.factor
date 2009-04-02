! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel assocs math sequences fry io.encodings.string
io.encodings.utf16n accessors arrays combinators destructors
cache namespaces init images.normalization alien.c-types locals
windows windows.usp10 windows.offscreen windows.gdi32
windows.ole32 windows.types windows.fonts ;
IN: windows.uniscribe

TUPLE: script-string metrics ssa size image string disposed ;

: make-script-string ( dc string -- script-string )
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

: draw-script-string ( script-string -- )
    ! ssa
    0 ! iX
    0 ! iY
    0 ! uOptions
    f ! prc
    0 ! iMinSel
    0 ! iMaxSel
    FALSE ! fDisabled
    ScriptStringOut ole32-error ;

: set-dc-font ( dc font -- )
    [ cache-font SelectObject win32-error=0/f ]
    [ background>> color>RGB SetBkColor drop ]
    [ foreground>> color>RGB SetTextColor drop ] 2tri ;

: script-string-size ( ssa -- dim )
    ScriptString_pSize
    dup win32-error=0/f
    [ SIZE-cx ] [ SIZE-cy ] bi 2array ;

: dc-metrics ( dc -- metrics )
    "TEXTMETRICW" <c-object> [ GetTextMetrics drop ] keep
    TEXTMETRIC>metrics ;

:: <script-string> ( font string -- script-string )
    #! Comments annotate BOA constructor arguments
    [| dc |
        dc font set-dc-font
        dc dc-metrics ! metrics
        dc string make-script-string dup :> ssa ! ssa
        dup script-string-size ! size
        dup dc [ ssa draw-script-string ] make-bitmap-image
        normalize-image ! image
        string ! string
        f script-string boa
    ] with-memory-dc ;

: text-position ( script-string -- loc ) drop { 0 0 } ;

M: script-string dispose* ssa>> <void*> ScriptStringFree ole32-error ;

SYMBOL: cached-script-strings

: cached-script-string ( string font -- script-string )
    cached-script-strings get-global [ <script-string> ] 2cache ;

[ <cache-assoc> cached-script-strings set-global ]
"windows.uniscribe" add-init-hook

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