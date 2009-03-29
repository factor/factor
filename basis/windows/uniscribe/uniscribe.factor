! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math sequences io.encodings.string io.encodings.utf16n
accessors arrays destructors alien.c-types windows windows.usp10
windows.offscreen ;
IN: windows.uniscribe

TUPLE: script-string pssa size image ;

: make-script-string ( dc string -- script-string )
    [ utf16n encode ] ! pString
    [ length ] bi ! cString
    dup 1.5 * 16 + ! cGlyphs -- MSDN says this is "recommended size"
    -1 ! iCharset -- Unicode
    SSA_GLYPHS ! dwFlags
    ... ! iReqWidth
    f ! psControl
    f ! psState
    f ! piDx
    f ! pTabdef
    ... ! pbInClass
    f <void*> ! pssa
    [ ScriptStringAnalyse ] keep
    [ win32-error=0/f ] [ |ScriptStringFree ] bi* ;

: draw-script-string ( script-string -- bitmap )
    ! ssa
    0 ! iX
    0 ! iY
    ETO_OPAQUE ! uOptions ... ????
    f ! prc
    0 ! iMinSel
    0 ! iMaxSel
    f ! fDisabled
    ScriptStringOut ;

: <script-string> ( string -- script-string )
    [
        ... dim ... [
            make-script-string |ScriptStringFree
            [ ]
            [ draw-script-string ]
            [
                ScriptString_pSize
                dup win32-error=0/f
                [ SIZE-cx ] [ SIZE-cy ] bi 2array
            ] tri
        ] make-bitmap-image
        script-string boa
    ] with-destructors ;

M: script-string dispose* pssa>> ScriptStringFree win32-error=0/f ;

: line-offset>x ( offset script-string -- x )
    pssa>> ! ssa
    swap ! icp
    ... ! fTrailing
    0 <int> [ ScriptStringCPtoX win32-error=0/f ] keep *int ;

: line-x>offset ( x script-string -- offset trailing )
    pssa>> ! ssa
    swap ! iX
    0 <int> ! pCh
    0 <int> ! piTrailing
    [ ScriptStringXtoCP win32-error=0/f ] 2keep [ *int ] bi@ ;