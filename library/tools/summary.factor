! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: inspector
USING: generic kernel namespaces prettyprint sequences strings
styles words ;

GENERIC: summary ( object -- string )

M: object summary
    "an instance of the " swap class word-name " class" append3 ;

M: word summary ( word -- )
    dup word-vocabulary [
        dup interned?
        "a word in the " "a word orphaned from the " ?
        swap word-vocabulary " vocabulary" append3
    ] [
        drop "a uniquely generated symbol"
    ] if ;

M: input summary ( input -- )
    "Input: " swap input-string
    dup string? [ unparse-short ] unless append ;

M: vocab-link summary ( vocab-link -- )
    [
        vocab-link-name dup %
        " vocabulary (" %
        words length #
        " words)" %
    ] "" make ;
