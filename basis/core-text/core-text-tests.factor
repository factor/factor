! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test core-text core-foundation
core-foundation.dictionaries destructors
arrays kernel generalizations math accessors
combinators hashtables ;
IN: core-text.tests

: test-font ( name -- object )
    kCTFontFamilyNameAttribute associate <CTFont> ;

[ ] [ "Helvetica" test-font CFRelease ] unit-test

[ ] [
    [
        kCTFontAttributeName "Helvetica" test-font &CFRelease 2array 1array
        <CFDictionary> &CFRelease drop
    ] with-destructors
] unit-test

: test-typographic-bounds ( string font -- ? )
    [
        test-font &CFRelease <CTLine> &CFRelease
        line-typographic-bounds {
            [ width>> float? ]
            [ ascent>> float? ]
            [ descent>> float? ]
            [ leading>> float? ]
        } cleave and and and
    ] with-destructors ;

[ t ] [ "Hello world" "Helvetica" test-typographic-bounds ] unit-test

[ t ] [ "Hello world" "Chicago" test-typographic-bounds ] unit-test

[ t ] [ "日本語" "Helvetica" test-typographic-bounds ] unit-test