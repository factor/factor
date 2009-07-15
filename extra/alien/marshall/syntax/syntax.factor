! Copyright (C) 2009 Jeremy Hughes.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.inline alien.inline.types alien.marshall
combinators effects generalizations kernel locals make namespaces
quotations sequences words alien.marshall.structs lexer parser
vocabs.parser multiline ;
IN: alien.marshall.syntax

:: marshalled-function ( name types effect -- word quot effect )
    name types effect factor-function
    [ in>> ]
    [ out>> types [ pointer-to-non-const-primitive? ] filter append ]
    bi <effect>
    [
        [
            types [ marshaller ] map , \ spread , ,
            types length , \ nkeep ,
            types [ out-arg-unmarshaller ] map
            effect out>> dup empty?
            [ drop ] [ first unmarshaller prefix ] if
            , \ spread ,
        ] [ ] make
    ] dip ;

: define-c-marshalled ( name types effect body -- )
    [
        [ marshalled-function define-declared ]
        [ prototype-string ] 3bi
    ] dip append-function-body c-strings get push ;

: define-c-marshalled' ( name effect body -- )
    [
        [ in>> ] keep
        [ marshalled-function define-declared ]
        [ out>> prototype-string' ] 3bi
    ] dip append-function-body c-strings get push ;

SYNTAX: CM-FUNCTION:
    function-types-effect parse-here define-c-marshalled ;

SYNTAX: M-FUNCTION:
    function-types-effect marshalled-function define-declared ;

SYNTAX: M-STRUCTURE:
    scan current-vocab parse-definition
    define-marshalled-struct ;

SYNTAX: CM-STRUCTURE:
    scan current-vocab parse-definition
    [ define-marshalled-struct ] [ nip define-c-struct ] 3bi ;
