USING: accessors arrays core-graphics.types core-text fonts io json
kernel locals math math.statistics namespaces opengl sequences
strings tools.test tools.time ui.text ui.text.core-text ui.text.private ;
IN: macos-text-profile
:: profile-hits ( string -- )
    sans-serif-font :> font
    font string cached-line :> line
    line metrics>> width>> 2 / :> x
    x 0 <CGPoint> :> point
    line line>> point CTLineGetStringIndexForPosition :> index
    index line utf16>line-index :> expected
    3 [ [ 100 [ font string cached-line drop ] times ] benchmark ] replicate median :> lookup
    3 [ [ 100 [ line line>> point CTLineGetStringIndexForPosition drop ] times ] benchmark ] replicate median :> native
    3 [ [ 100 [ index line utf16>line-index expected assert= ] times ] benchmark ] replicate median :> mapping
    3 [ [ 100 [ x font string x>offset expected assert= ] times ] benchmark ] replicate median :> full
    string length :> chars
    { "100-hits-ns" chars lookup native mapping full } >json print flush ;
f gl-scale-factor set-global
100000 CHAR: W <string> profile-hits
100000 CHAR: 中 <string> profile-hits
20000 [ "ab😀cd" ] replicate concat profile-hits
