! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data arrays assocs cache
classes.struct combinators destructors fonts init io.encodings.string
io.encodings.utf16n kernel literals locals math namespaces sequences
windows.errors windows.fonts windows.gdi32 windows.offscreen
windows.ole32 windows.types windows.usp10 ;
IN: windows.uniscribe

TUPLE: script-string < disposable font string metrics ssa size image ;

: line-offset>x ( n script-string -- x )
    2dup string>> length = [
        ssa>> ! ssa
        swap 1 - ! icp
        TRUE ! fTrailing
    ] [
        ssa>>
        swap ! icp
        FALSE ! fTrailing
    ] if
    { int } [ ScriptStringCPtoX check-ole32-error ] with-out-parameters ;

: x>line-offset ( x script-string -- n trailing )
    ssa>> ! ssa
    swap ! iX
    { int int } [ ScriptStringXtoCP check-ole32-error ] with-out-parameters ;

<PRIVATE

CONSTANT: ssa-dwFlags flags{ SSA_GLYPHS SSA_FALLBACK SSA_TAB }

: make-ssa ( dc script-string -- ssa )
    dup selection? [ string>> ] when
    [ utf16n encode ] ! pString
    [ length ] bi ! cString
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
    [ background>> color>RGB SetBkColor drop ]
    [ foreground>> color>RGB SetTextColor drop ] 2bi ;

: selection-start/end ( script-string -- iMinSel iMaxSel )
    string>> dup selection? [ [ start>> ] [ end>> ] bi ] [ drop 0 0 ] if ;

: draw-script-string ( ssa size script-string -- )
    [
        0 ! iX
        0 ! iY
        ETO_OPAQUE ! uOptions
    ]
    [ [ { 0 0 } ] dip <RECT> ]
    [ selection-start/end ] tri*
    ! iMinSel
    ! iMaxSel
    FALSE ! fDisabled
    ScriptStringOut check-ole32-error ;

:: render-image ( dc ssa script-string -- image )
    script-string size>> :> size
    size dc
    [ ssa size script-string draw-script-string ] make-bitmap-image ;

: set-dc-font ( dc font -- )
    cache-font SelectObject win32-error=0/f ;

: ssa-size ( ssa -- dim )
    ScriptString_pSize
    dup win32-error=0/f
    [ cx>> ] [ cy>> ] bi 2array ;

: dc-metrics ( dc -- metrics )
    TEXTMETRICW <struct>
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

[ <cache-assoc> &dispose cached-script-strings set-global ]
"windows.uniscribe" add-startup-hook
