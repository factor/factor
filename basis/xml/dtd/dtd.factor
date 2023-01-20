! Copyright (C) 2005, 2009 Daniel Ehrenberg, Slava Pestov
! See https://factorcode.org/license.txt for BSD license.
USING: combinators hashtables kernel namespaces xml.data
xml.errors xml.name xml.state xml.tokenize ;
IN: xml.dtd

: take-decl-contents ( -- first second )
    pass-blank take-word pass-blank ">" take-string ;

: take-element-decl ( -- element-decl )
    take-decl-contents <element-decl> ;

: take-attlist-decl ( -- attlist-decl )
    take-decl-contents <attlist-decl> ;

: take-notation-decl ( -- notation-decl )
    take-decl-contents <notation-decl> ;

UNION: dtd-acceptable
    directive comment instruction ;

: take-entity-def ( var -- entity-name entity-def )
    [
        take-word pass-blank get-char {
            { CHAR: ' [ parse-quote ] }
            { CHAR: \" [ parse-quote ] }
            [ drop take-external-id close ]
        } case
    ] dip '[ swap _ [ ?set-at ] change ] 2keep ;

: take-entity-decl ( -- entity-decl )
    pass-blank get-char {
        { CHAR: % [ next pass-blank pe-table take-entity-def t ] }
        [ drop extra-entities take-entity-def f ]
    } case close <entity-decl> ;

: take-inner-directive ( string -- directive )
    {
        { "ELEMENT" [ take-element-decl ] }
        { "ATTLIST" [ take-attlist-decl ] }
        { "ENTITY" [ take-entity-decl ] }
        { "NOTATION" [ take-notation-decl ] }
        [ bad-directive ]
    } case ;
