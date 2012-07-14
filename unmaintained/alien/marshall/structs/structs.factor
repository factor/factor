! Copyright (C) 2009 Jeremy Hughes.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.marshall arrays assocs
classes.tuple combinators destructors generalizations generic
kernel libc locals parser quotations sequences slots words
alien.structs lexer vocabs.parser fry effects alien.data ;
IN: alien.marshall.structs

<PRIVATE
: define-struct-accessor ( class name quot -- )
    [ "accessors" create create-method dup make-inline ] dip define ;

: define-struct-getter ( class name word type -- )
    [ ">>" append \ underlying>> ] 2dip
    struct-field-unmarshaller \ call 4array >quotation
    define-struct-accessor ;

: define-struct-setter ( class name word type -- )
    [ "(>>" prepend ")" append ] 2dip
    marshaller [ underlying>> ] \ bi* roll 4array >quotation
    define-struct-accessor ;

: define-struct-accessors ( class name type reader writer -- )
    [ dup define-protocol-slot ] 3dip
    [ drop swap define-struct-getter ]
    [ nip swap define-struct-setter ] 5 nbi ;

: define-struct-constructor ( class -- )
    {
        [ name>> "<" prepend ">" append create-in ]
        [ '[ _ new ] ]
        [ name>> '[ _ malloc-object >>underlying ] append ]
        [ name>> 1array ]
    } cleave { } swap <effect> define-declared ;
PRIVATE>

:: define-struct-tuple ( name -- )
    name create-in :> class
    class struct-wrapper { } define-tuple-class
    class define-struct-constructor
    name c-type fields>> [
        class swap
        {
            [ name>> H{ { CHAR: space CHAR: - } } substitute ]
            [ type>> ] [ reader>> ] [ writer>> ]
        } cleave define-struct-accessors
    ] each ;

: define-marshalled-struct ( name vocab fields -- )
    [ define-struct ] [ 2drop define-struct-tuple ] 3bi ;
