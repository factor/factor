USING: accessors alien.c-types alien.data continuations destructors fonts fonts.shaping
kernel locals math namespaces opengl tools.test windows.offscreen windows.ole32 windows.types
windows.uniscribe windows.uniscribe.private windows.usp10 ;
IN: windows.uniscribe.shaping.tests

:: native-position ( font text scale index -- x )
    [ :> dc
        dc font set-dc-font
        dc text font scale make-ssa-with-font :> ssa
        ssa void* <ref> &ScriptStringFree drop
        ssa text index >utf16-index FALSE { int }
        [ ScriptStringCPtoX check-ole32-error ] with-out-parameters
    ] with-memory-dc ;

: tab-font ( -- font ) "Arial" <font> 32 font-with-tab-width ;

{ 32 } [ tab-font "a\tb" 1 2 native-position ] unit-test
{ 64 } [ tab-font "a\tb\tc" 1 4 native-position ] unit-test
{ 64 } [ tab-font "a\tb" 2 2 native-position ] unit-test
{ 48 } [ tab-font "a\tb" 1.5 2 native-position ] unit-test
{ 11 } [ "Arial" <font> 10.5 font-with-tab-width "\tx" 1 1 native-position ] unit-test
{ 1 } [ "Arial" <font> 0.01 font-with-tab-width "\tx" 1 1 native-position ] unit-test

! Strong LTR and RTL runs retain their own internal ordering, while the
! explicit paragraph direction changes where their visual runs occur.
{ t } [
    "Arial" <font> left-to-right font-with-direction
    "abc \u0005d0\u0005d1\u0005d2" 1 0 native-position
    "Arial" <font> right-to-left font-with-direction
    "abc \u0005d0\u0005d1\u0005d2" 1 0 native-position <
] unit-test

{ t } [
    "Arial" <font> right-to-left font-with-direction
    "abc \u0005d0\u0005d1\u0005d2" 1 4 native-position
    "Arial" <font> right-to-left font-with-direction
    "abc \u0005d0\u0005d1\u0005d2" 1 5 native-position >
] unit-test

{ t } [
    "Arial" <font> "abc \u0005d0\u0005d1\u0005d2" 1 0 native-position
    "Arial" <font> left-to-right font-with-direction
    "abc \u0005d0\u0005d1\u0005d2" 1 0 native-position =
] unit-test

! Device-coordinate tab stops must fit the native signed integer field.
[
    "Arial" <font> 0x80000000 font-with-tab-width "\tx" 1 1 native-position drop
] must-fail

! The production cached layout and deferred raster use the same options.
:: shaped-layout-dpi? ( -- caret? raster? )
    gl-scale-factor get-global :> previous
    [ [
        1.5 gl-scale-factor set-global
        tab-font "a\tb" <script-string> &dispose :> delayed
        tab-font "a\tb" <script-string> &dispose script-string>image :> reference
        2 delayed line-offset>x 48 =
        1.0 gl-scale-factor set-global
        delayed script-string>image bitmap>> reference bitmap>> =
    ] with-destructors ] [ previous gl-scale-factor set-global ] finally ;

{ t t } [ shaped-layout-dpi? ] unit-test

{ t } [
    [ [let "Arial" <font> right-to-left font-with-direction :> font
      font "abc אבג" <script-string> &dispose :> layout
      0 layout line-offset>x font "abc אבג" 1 0 native-position =
    ] ] with-destructors
] unit-test

! Visual edges of an RTL paragraph map to reversed logical boundaries.
{ 3 0 } [
    [ "Arial" <font> right-to-left font-with-direction "אבג" <script-string> &dispose
      [ -100 swap x>line-offset + ] [ 1000 swap x>line-offset + ] bi
    ] with-destructors
] unit-test
