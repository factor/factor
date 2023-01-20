! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: tools.test core-foundation core-foundation.dictionaries
arrays destructors core-foundation.strings kernel namespaces ;
IN: core-foundation.dictionaries.tests

{ } [ { } <CFDictionary> CFRelease ] unit-test

{ "raps in the back of cars and doesn't afraid of anything" } [
    [
        "cpst" <CFString> &CFRelease dup "key" set
        "raps in the back of cars and doesn't afraid of anything" <CFString> &CFRelease
        2array 1array <CFDictionary> &CFRelease
        "key" get
        CFDictionaryGetValue
        dup [ CF>string ] when
    ] with-destructors
] unit-test
