USING: accessors alien.c-types alien.data arrays destructors fonts
kernel locals math sequences tools.test windows.ole32 windows.types
windows.uniscribe windows.uniscribe.private windows.usp10 ;
IN: windows.uniscribe.indices.tests

{ { 0 1 3 4 6 } } [ "a\u01f600b\u01f600" codepoint-boundaries ] unit-test
{ { 0 0 1 1 2 3 3 4 4 4 } } [
    10 <iota> [ 1 - { 0 1 3 4 6 } swap boundary>codepoint ] map
] unit-test
{ { 0 } 0 0 } [
    "" codepoint-boundaries
    { 0 } -1 boundary>codepoint { 0 } 100 boundary>codepoint
] unit-test

:: reference-caret ( n script -- x )
    script string>> :> text
    text n >utf16-index :> index
    script ssa>> n text length = [ index 1 - TRUE ] [ index FALSE ] if
    { int } [ ScriptStringCPtoX check-ole32-error ] with-out-parameters ;

:: reference-hit ( x script -- n trailing )
    script string>> :> text
    script ssa>> x { int int }
    [ ScriptStringXtoCP check-ole32-error ] with-out-parameters :> trailing :> n
    n 0 < [ n trailing ] [
        text n >codepoint-index :> start
        start text n trailing + >codepoint-index start -
    ] if ;

:: native-index-equivalence? ( text -- forward? backward? )
    monospace-font text <script-string> [ :> script
        text length 1 + <iota> [ :> n
            n script line-offset>x n script reference-caret =
        ] map [ ] all?
        script size>> first 40 + <iota> [ 20 - :> x
            x script x>line-offset 2array x script reference-hit 2array =
        ] map [ ] all?
    ] with-disposal ;

{ t t } [ "a\u01f600b" native-index-equivalence? ] unit-test
{ t t } [ "a\u000301" native-index-equivalence? ] unit-test
{ t t } [ "\u000915\u00093f" native-index-equivalence? ] unit-test
{ t t } [ "abc \u0005d0\u0005d1\u0005d2 xyz" native-index-equivalence? ] unit-test
