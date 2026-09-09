USING: accessors alien.c-types alien.data arrays destructors fonts images
io.encodings.string io.encodings.utf16 kernel locals math sequences strings
tools.test windows.offscreen windows.ole32 windows.types
windows.uniscribe windows.uniscribe.private windows.usp10 ;
IN: windows.uniscribe.expansion.tests

:: max-capacity-analysis ( dc text -- ssa )
    text utf16n encode :> encoded
    dc encoded encoded length 2 /i 65535 -1 ssa-dwFlags 0 f f f f f
    { void* } [ ScriptStringAnalyse check-ole32-error ] with-out-parameters
    dup void* <ref> &ScriptStringFree drop ;

:: layout-width ( font text -- width )
    font text <script-string> [ size>> first ] with-disposal ;

:: repeated-width? ( name codepoint count -- ? )
    name <font> :> font
    font 1 codepoint <string> layout-width count *
    font count codepoint <string> layout-width = ;

! These codepoints decompose and acquire dotted-circle glyphs: native
! capacity 4*n is still insufficient; 4*n+1 is the observed minimum.
{ t } [ "Segoe UI" 0x0f77 100 repeated-width? ] unit-test
{ t } [ "Segoe UI" 0x0f79 1000 repeated-width? ] unit-test
{ t } [ "Microsoft Himalaya" 0x0f77 1000 repeated-width? ] unit-test
{ t } [ "Segoe UI" 0x0ccb 100 repeated-width? ] unit-test
{ t } [ "Nirmala UI" 0x0ccb 1000 repeated-width? ] unit-test

:: matches-reference? ( codepoint count -- ? )
    count codepoint <string> :> text
    "Segoe UI" <font> text <script-string> [ :> script
        [ :> dc
            script dc configure-script-dc
            dc text max-capacity-analysis :> reference
            script size>> reference ssa-size =
            count [ :> index
                index script line-offset>x
                reference index FALSE { int }
                [ ScriptStringCPtoX check-ole32-error ] with-out-parameters =
            ] all-integers? and
        ] with-memory-dc
    ] with-disposal ;

{ t } [ 0x0f77 1000 matches-reference? ] unit-test
{ t } [ 0x0ccb 1000 matches-reference? ] unit-test

:: text-image ( text reference? -- image )
    "Segoe UI" <font> text <script-string> [ :> script
        reference? [
            [ :> dc
                script dc configure-script-dc
                dc text max-capacity-analysis :> reference
                script reference ssa-size >>size drop
                dc reference script render-image
            ] with-memory-dc
        ] [ script script-string>image ] if
    ] with-disposal ;

:: raster-matches-reference? ( codepoint -- ? )
    100 codepoint <string> :> text
    text f text-image :> actual
    text t text-image :> reference
    actual dim>> reference dim>> =
    actual bitmap>> reference bitmap>> = and ;

{ t } [ 0x0f77 raster-matches-reference? ] unit-test
{ t } [ 0x0ccb raster-matches-reference? ] unit-test
{ t } [ "Consolas" CHAR: a 100 repeated-width? ] unit-test
{ 65535 } [ 50000 uniscribe-glyph-capacity ] unit-test

