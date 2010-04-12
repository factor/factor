! Copyright (C) 2005, 2010 Slava Pestov, Alex Chapman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays alien alien.c-types alien.arrays
alien.strings kernel math namespaces parser sequences words
quotations math.parser splitting grouping effects assocs
combinators lexer strings.parser alien.parser fry vocabs.parser
words.constant alien.libraries ;
IN: alien.syntax

SYNTAX: DLL" lexer get skip-blank parse-string dlopen suffix! ;

SYNTAX: ALIEN: 16 scan-base <alien> suffix! ;

SYNTAX: BAD-ALIEN <bad-alien> suffix! ;

SYNTAX: LIBRARY: scan current-library set ;

SYNTAX: FUNCTION:
    (FUNCTION:) define-declared ;

SYNTAX: CALLBACK:
    (CALLBACK:) define-inline ;

SYNTAX: TYPEDEF:
    scan-c-type CREATE-C-TYPE dup save-location typedef ;

SYNTAX: C-ENUM:
    scan dup "f" =
    [ drop ]
    [ (CREATE-C-TYPE) dup save-location int swap typedef ] if
    0 parse-enum-members ;

SYNTAX: C-TYPE:
    void CREATE-C-TYPE typedef ;

SYNTAX: &:
    scan current-library get '[ _ _ address-of ] append! ;

SYNTAX: C-GLOBAL: scan-c-type CREATE-WORD define-global ;

SYNTAX: pointer:
    scan-c-type <pointer> suffix! ;
