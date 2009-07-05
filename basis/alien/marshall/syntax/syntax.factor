! Copyright (C) 2009 Jeremy Hughes.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.inline alien.inline.types alien.marshall
combinators effects generalizations kernel locals namespaces
quotations sequences words ;
IN: alien.marshall.syntax

:: marshalled-function ( function types effect -- word quot effect )
    function types effect annotate-effect factor-function
    [ in>> ]
    [ out>> types [ pointer-to-primitive? ] filter append ]
    bi <effect>
    [
        types [ marshaller ] map \ spread rot
        types length \ nkeep
        types [ out-arg-unmarshaller ] map \ spread
        7 narray >quotation
    ] dip ;

: define-c-marshalled ( function types effect -- )
    [ marshalled-function define-declared ] 3keep
    c-function-string c-strings get push ;

: define-c-marshalled' ( function effect -- )
    [ in>> ] keep [ marshalled-function define-declared ] 3keep
    out>> c-function-string' c-strings get push ;

SYNTAX: C-MARSHALLED:
    function-types-effect define-c-marshalled ;

SYNTAX: MARSHALLED:
    function-types-effect marshalled-function define-declared ;
