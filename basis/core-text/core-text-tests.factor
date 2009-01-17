! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test core-text core-foundation
core-foundation.dictionaries destructors
arrays kernel ;
IN: core-text.tests

[ ] [ "Helvetica" 12 <CTFont> CFRelease ] unit-test

[ ] [
    [
        kCTFontAttributeName "Helvetica" 64 <CTFont> &CFRelease 2array 1array
        <CFDictionary> &CFRelease drop
    ] with-destructors
] unit-test