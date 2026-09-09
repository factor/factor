USING: accessors alien.c-types alien.data colors destructors fonts
images kernel locals math math.bitwise sequences specialized-arrays
tools.test windows.fonts windows.gdi32 windows.offscreen windows.types
windows.uniscribe windows.uniscribe.private windows.usp10 ;
SPECIALIZED-ARRAY: uint32_t
IN: windows.uniscribe.raster.tests

:: raw-script-raster ( font text -- image )
    font text <script-string> [ :> script
        [ :> dc
            script dc configure-script-dc
            dc text make-ssa :> ssa
            ssa void* <ref> &ScriptStringFree drop
            script size>> dc [
                ssa script size>> script draw-script-string
            ] make-bitmap-image
        ] with-memory-dc
    ] with-disposal ;

:: grayscale-pixel? ( pixel -- ? )
    pixel 255 bitand pixel -8 shift 255 bitand =
    pixel -8 shift 255 bitand pixel -16 shift 255 bitand = and ;

: grayscale-raster? ( image -- ? )
    bitmap>> uint32_t cast-array [ grayscale-pixel? ] all? ;

: smooth-raster? ( image -- ? )
    bitmap>> uint32_t cast-array [ 255 bitand dup 0 > swap 255 < and ] any? ;

: mask-font ( -- font )
    "Arial" <font> 48 font-with-size
    0 0 0 0 <rgba> font-with-background ;

! Exercise the exact DC configuration and fresh SSA used by rendering.
{ t t } [
    mask-font "office" raw-script-raster
    [ grayscale-raster? ] [ smooth-raster? ] bi
] unit-test

{ t t } [
    "Arial" <font> 48 font-with-size
    "office" 1 4 COLOR: red <selection> raw-script-raster
    [ grayscale-raster? ] [ smooth-raster? ] bi
] unit-test

! The quality must also reach Uniscribe's fallback fonts.
{ t t } [
    mask-font "\u01f600\u000e01\u000e49" raw-script-raster
    [ grayscale-raster? ] [ smooth-raster? ] bi
] unit-test

{ t } [
    "Arial" <font> dup cache-font
    swap ANTIALIASED_QUALITY cache-font-with-quality = not
] unit-test

! Opaque, unselected text keeps the original system font quality.
:: opaque-default-quality? ( -- ? )
    "Arial" <font> "office" <script-string> [ :> script
        [ :> dc
            script dc configure-script-dc
            dc script font>> cache-font SelectObject script font>> cache-font =
        ] with-memory-dc
    ] with-disposal ;

{ t } [ opaque-default-quality? ] unit-test

ERROR: interrupted-script-render ;

! A temporary SSA has one owner, even when rendering exits through an error.
! Registering both error-only and unconditional cleanup double-freed it.
:: interrupted-render ( shaped? -- )
    "Arial" <font> "abc" <script-string> [ :> script
        [ :> dc
            script dc configure-script-dc
            shaped? [ dc "abc" script font>> script backing-scale>> make-ssa-with-font ]
            [ dc "abc" make-ssa ] if
            void* <ref> &ScriptStringFree drop
            interrupted-script-render
        ] with-memory-dc
    ] with-disposal ;

[ f interrupted-render ] [ interrupted-script-render? ] must-fail-with
[ t interrupted-render ] [ interrupted-script-render? ] must-fail-with

! Crop coordinates are top-down, while DIB storage starts with the bottom row.
! Keep every channel byte and leave the source bitmap untouched.
:: cropped-test-bitmap ( bounds -- pixels dimensions original )
    <image> { 3 3 } >>dim
    B{ 1 2 3 4  5 6 7 8  9 10 11 12
       13 14 15 16  17 18 19 20  21 22 23 24
       25 26 27 28  29 30 31 32  33 34 35 36 } >>bitmap :> source
    source bounds crop-text-bitmap [ bitmap>> ] [ dim>> ] bi
    source bitmap>> ;

{ B{ 17 18 19 20 21 22 23 24 29 30 31 32 33 34 35 36 } { 2 2 }
  B{ 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20
     21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 } }
[ { 1 0 3 2 } cropped-test-bitmap ] unit-test

{ B{ 1 2 3 4 5 6 7 8 9 10 11 12 } { 3 1 } }
[ { 0 2 3 3 } cropped-test-bitmap drop ] unit-test

{ B{ } { 0 2 } } [ { 1 0 1 2 } cropped-test-bitmap drop ] unit-test
{ B{ } { 2 0 } } [ { 0 1 2 1 } cropped-test-bitmap drop ] unit-test
