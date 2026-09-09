USING: accessors alien.syntax arrays assocs colors core-foundation
core-foundation.attributed-strings core-foundation.numbers core-text
core-text.fonts destructors fonts io json kernel locals math math.functions
math.order namespaces opengl ranges sequences sets ui.text ui.text.private ui.text.core-text unicode ;
IN: shaping-probe
: emit ( obj -- ) >json print flush ;
:: glyph-count ( string font mode -- count )
    [
        font cache-font COLOR: white make-attributes clone :> attrs
        mode kCTLigatureAttributeName attrs set-at
        string attrs <CFAttributedString> &CFRelease
        CTLineCreateWithAttributedString &CFRelease CTLineGetGlyphCount
    ] with-destructors ;
:: probe ( string -- )
    sans-serif-font "Times" >>name 40 >>size :> font
    { 0 1 2 } [ string font rot glyph-count ] map :> counts
    font string string-dim first ceiling >integer :> width
    -10 width 10 + [a..b] [ font string x>offset ] map members :> hits
    string length 1 + <iota> [ font string offset>x ] map :> offsets
    { string counts hits offsets } emit ;
f gl-scale-factor set-global
{ "fi" "fl" "ffi" "ffl" "st" "é" "ạ́" "👩‍💻" "👨‍👩‍👧‍👦" "👍🏽" "🇺🇸" "1️⃣" "لا" "العربية" "क्षि" "বাংলা" "ไทย" "abc אבג def" } [ probe ] each

{ "Times" "Hoefler Text" "Baskerville" "Didot" } [| name | { "fi" "ffi" "ffl" "st" "ct" } [| string | { 0 1 2 } [ string sans-serif-font name >>name 40 >>size rot glyph-count ] map string name 3array emit ] each ] each

{ { 4 7 } { 1 5 } { 5 9 } { 0 11 } } [| pair | sans-serif-font "Times" >>name 40 >>size "abc אבג def" cached-line pair first2 line-selection-spans pair 2array emit ] each
USING: strings ;
{ { 0 } { 0x200d } { 0x200b } { 0x202a 0x202c } } [ >string probe ] each
