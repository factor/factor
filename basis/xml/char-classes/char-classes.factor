! Copyright (C) 2005, 2007 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences unicode.syntax math math.order combinators ;
IN: xml.char-classes

CATEGORY: 1.0name-start* Ll Lu Lo Lt Nl \u000559\u0006E5\u0006E6_ ;
: 1.0name-start? ( char -- ? )
    dup 1.0name-start*? [ drop t ] 
    [ HEX: 2BB HEX: 2C1 between? ] if ;

CATEGORY: 1.0name-char Ll Lu Lo Lt Nl Mc Me Mn Lm Nd _-.\u000387 ;

CATEGORY: 1.1name-start Ll Lu Lo Lm Ln Nl _ ;

CATEGORY: 1.1name-char Ll Lu Lo Lm Ln Nl Mc Mn Nd Pc Cf _-.\u0000b7 ;

: name-start? ( 1.0? char -- ? )
    swap [ 1.0name-start? ] [ 1.1name-start? ] if ;

: name-char? ( 1.0? char -- ? )
    swap [ 1.0name-char? ] [ 1.1name-char? ] if ;

: text? ( 1.0? char -- ? )
    ! 1.0:
    ! #x9 | #xA | #xD | [#x20-#xD7FF] | [#xE000-#xFFFD] | [#x10000-#x10FFFF]
    ! 1.1:
    ! [#x1-#xD7FF] | [#xE000-#xFFFD] | [#x10000-#x10FFFF]
    {
        { [ dup HEX: 20 < ] [ "\t\r\n" member? and ] }
        { [ nip dup HEX: D800 < ] [ drop t ] }
        { [ dup HEX: E000 < ] [ drop f ] }
        [ { HEX: FFFE HEX: FFFF } member? not ]
    } cond ;
