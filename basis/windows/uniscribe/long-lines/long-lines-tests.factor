USING: accessors alien.c-types alien.data fonts kernel locals math
math.bitwise sequences strings tools.test windows.offscreen
windows.uniscribe windows.uniscribe.private windows.usp10 ;
IN: windows.uniscribe.long-lines.tests

:: correct-long-width? ( count -- ? )
    "Consolas" <font> :> font
    font "a" cached-script-string size>> first count *
    font count CHAR: a <string> cached-script-string size>> first = ;

{ t } [ 32764 correct-long-width? ] unit-test
{ t } [ 32767 correct-long-width? ] unit-test
{ t } [ 40000 correct-long-width? ] unit-test
{ t } [ 50000 correct-long-width? ] unit-test
{ 65535 } [ 50000 uniscribe-glyph-capacity ] unit-test

:: long-flags ( text flags -- result )
    [ :> dc
        dc "Consolas" <font> set-dc-font
        dc text flags uniscribe-long-line-flags
    ] with-memory-dc ;

! Removing fallback never removes other layout flags.
{ t } [
    40000 CHAR: a <string> ssa-dwFlags SSA_RTL bitor long-flags
    ssa-dwFlags SSA_RTL bitor SSA_FALLBACK bitnot bitand =
] unit-test

! Controls and non-ASCII scripts must retain native fallback.
{ t } [
    40000 CHAR: a <string> "\t" append ssa-dwFlags long-flags ssa-dwFlags =
] unit-test
{ t } [
    40000 0x0627 <string> ssa-dwFlags long-flags ssa-dwFlags =
] unit-test
{ t } [
    40000 CHAR: a <string> "\u01f600" append ssa-dwFlags long-flags ssa-dwFlags =
] unit-test

! A failed coverage query is never taken as proof that fallback is safe
! to disable; this also exercises the native GDI_ERROR return path.
{ t } [
    f 40000 CHAR: a <string> ssa-dwFlags uniscribe-long-line-flags ssa-dwFlags =
] unit-test

{ 40000 } [
    "Consolas" <font> 40000 0x0627 <string> cached-script-string
    ssa>> ScriptString_pcOutChars int deref
] unit-test

{ t } [
    "Consolas" <font> "\u01f600" cached-script-string size>> first
    "Consolas" <font> "a" cached-script-string size>> first >
] unit-test
