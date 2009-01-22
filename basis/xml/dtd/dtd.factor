! Copyright (C) 2005, 2009 Daniel Ehrenberg, Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: xml.tokenize xml.data xml.state kernel sequences ascii
fry xml.errors combinators hashtables namespaces xml.entities
strings ;
IN: xml.dtd

: take-word ( -- string )
    [ get-char blank? ] take-until ;

: take-decl-contents ( -- first second )
    pass-blank take-word pass-blank ">" take-string ;

: take-element-decl ( -- element-decl )
    take-decl-contents <element-decl> ;

: take-attlist-decl ( -- attlist-decl )
    take-decl-contents <attlist-decl> ;

: take-notation-decl ( -- notation-decl )
    take-decl-contents <notation-decl> ; 

: take-until-one-of ( seps -- str sep )
    '[ get-char _ member? ] take-until get-char ;

: take-system-id ( -- system-id )
    parse-quote <system-id> close ;

: take-public-id ( -- public-id )
    parse-quote parse-quote <public-id> close ;

UNION: dtd-acceptable
    directive comment instruction ;

: (take-external-id) ( token -- external-id )
    pass-blank {
        { "SYSTEM" [ take-system-id ] }
        { "PUBLIC" [ take-public-id ] }
        [ bad-external-id ]
    } case ;

: take-external-id ( -- external-id )
    take-word (take-external-id) ;

: only-blanks ( str -- )
    [ blank? ] all? [ bad-decl ] unless ;
: take-entity-def ( var -- entity-name entity-def )
    [
        take-word pass-blank get-char {
            { CHAR: ' [ parse-quote ] }
            { CHAR: " [ parse-quote ] }
            [ drop take-external-id ]
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
