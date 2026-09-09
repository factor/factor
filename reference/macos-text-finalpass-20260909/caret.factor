USING: accessors arrays core-graphics.types core-text fonts io
io.encodings.string io.encodings.utf16 json kernel locals math
math.statistics namespaces opengl sequences strings tools.test tools.time
ui.text ui.text.core-text ui.text.private ;
IN: macos-caret-audit
:: old-hit ( x font string -- n )
    font string cached-line line>>
    x gl-scale 0 <CGPoint> CTLineGetStringIndexForPosition
    2 * 0 swap string utf16n encode subseq utf16n decode length ;
:: compare-hits ( string -- )
    sans-serif-font :> font
    font string cached-line metrics>> width>> 2 / gl-unscale :> x
    x font string old-hit :> expected
    x font string x>offset expected assert=
    3 [ [ 100 [ x font string old-hit drop ] times ] benchmark ] replicate median :> old
    3 [ [ 100 [ x font string x>offset drop ] times ] benchmark ] replicate median :> new
    string length :> chars
    { "100-warm-hits-ns" chars old new } >json print flush ;
f gl-scale-factor set-global
100000 CHAR: W <string> compare-hits
100000 CHAR: 中 <string> compare-hits
20000 [ "ab😀cd" ] replicate concat compare-hits
