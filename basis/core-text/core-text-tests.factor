! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test core-text core-foundation
core-foundation.dictionaries destructors
arrays kernel generalizations math accessors
combinators ;
IN: core-text.tests

: test-font ( -- object )
    "Helvetica" 12 <CTFont> ;

[ ] [ test-font CFRelease ] unit-test

[ ] [
    [
        kCTFontAttributeName test-font &CFRelease 2array 1array
        <CFDictionary> &CFRelease drop
    ] with-destructors
] unit-test

: test-typographic-bounds ( string -- ? )
    [
        test-font &CFRelease <CTLine> &CFRelease
        line-typographic-bounds {
            [ width>> float? ]
            [ ascent>> float? ]
            [ descent>> float? ]
            [ leading>> float? ]
        } cleave and and and
    ] with-destructors ;

[ t ] [ "Hello world" test-typographic-bounds ] unit-test

[ t ] [ "日本語" test-typographic-bounds ] unit-test