! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays byte-arrays kernel make math
math.parser prettyprint sequences smalltalk.ast strings
splitting ;
IN: smalltalk.printer

GENERIC: smalltalk>string ( object -- string )

M: real smalltalk>string number>string ;

M: string smalltalk>string
    [
        "'" %
        [ dup CHAR: ' = [ dup , , ] [ , ] if ] each
        "'" %
    ] "" make ;

GENERIC: array-element>string ( object -- string )

M: object array-element>string smalltalk>string ;

M: array array-element>string
    [ array-element>string ] map join-words "(" ")" surround ;

M: array smalltalk>string
    array-element>string "#" prepend ;

M: byte-array smalltalk>string
    [ number>string ] { } map-as join-words "#[" "]" surround ;

M: symbol smalltalk>string
    name>> smalltalk>string "#" prepend ;

M: object smalltalk>string unparse-short ;
