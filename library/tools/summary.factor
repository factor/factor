! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: prettyprint
USING: generic kernel namespaces prettyprint sequences strings
styles words ;

GENERIC: summary ( object -- string )

M: object summary
    "an instance of the " swap class word-name " class" append3 ;

M: input summary
    "Input: " swap input-string dup string?
    [ "\n" split1 "..." "" ? append ] [ unparse-short ] if
    append ;

M: vocab-link summary
    [
        vocab-link-name dup %
        " vocabulary (" %
        words length #
        " words)" %
    ] "" make ;
