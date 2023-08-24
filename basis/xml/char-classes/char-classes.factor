! Copyright (C) 2005, 2009 Daniel Ehrenberg
! See https://factorcode.org/license.txt for BSD license.
USING: kernel sequences unicode.categories math math.order
hints combinators.short-circuit ;
IN: xml.char-classes

CATEGORY: 1.0name-start
    Ll Lu Lo Lt Nl | {
        [ 0x2BB 0x2C1 between? ]
        [ "\u000559\u0006E5\u0006E6_:" member? ]
    } 1|| ;

CATEGORY: 1.0name-char
    Ll Lu Lo Lt Nl Mc Me Mn Lm Nd |
    "_-.\u000387:" member? ;

CATEGORY: 1.1name-start
    Ll Lu Lo Lm Nl |
    "_:" member? ;

CATEGORY: 1.1name-char
    Ll Lu Lo Lm Nl Mc Mn Nd Pc Cf |
    "_-.\u0000b7:" member? ;

: name-start? ( 1.0? char -- ? )
    swap [ 1.0name-start? ] [ 1.1name-start? ] if ;

: name-char? ( 1.0? char -- ? )
    swap [ 1.0name-char? ] [ 1.1name-char? ] if ;

HINTS: name-start? { object fixnum } ;
HINTS: name-char? { object fixnum } ;

<PRIVATE

: 1.0-text? ( char -- ? )
    ! 1.0:
    ! #x9 | #xA | #xD | [#x20-#xD7FF] | [#xE000-#xFFFD] | [#x10000-#x10FFFF]
    {
        [ 0x20 0xD7FF between? ]
        [ "\t\r\n" member? ]
        [ 0xE000 0xFFFD between? ]
        [ 0x10000 0x10FFFF between? ]
    } 1|| ; inline

: 1.1-text? ( char -- ? )
    ! 1.1:
    ! [#x1-#xD7FF] | [#xE000-#xFFFD] | [#x10000-#x10FFFF]
    {
        [ 0x1 0xD7FF between? ]
        [ 0xE000 0xFFFD between? ]
        [ 0x10000 0x10FFFF between? ]
    } 1|| ; inline

PRIVATE>

: text? ( 1.0? char -- ? )
    swap [ 1.0-text? ] [ 1.1-text? ] if ;

HINTS: text? { object fixnum } ;
