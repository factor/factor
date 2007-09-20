! Copyright (C) 2005, 2007 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences unicode math ;
IN: xml.char-classes

CATEGORY: 1.0name-start* Ll Lu Lo Lt Nl \u0559\u06E5\u06E6_ ;
: 1.0name-start? ( char -- ? )
    dup 1.0name-start*? [ drop t ] 
    [ HEX: 2BB HEX: 2C1 between? ] if ;

CATEGORY: 1.0name-char Ll Lu Lo Lt Nl Mc Me Mn Lm Nd _-.\u0387 ;

CATEGORY: 1.1name-start Ll Lu Lo Lm Ln Nl _ ;

CATEGORY: 1.1name-char Ll Lu Lo Lm Ln Nl Mc Mn Nd Pc Cf _-.\u00b7 ;

: name-start? ( 1.0? char -- ? )
    swap [ 1.0name-start? ] [ 1.1name-start? ] if ;

: name-char? ( 1.0? char -- ? )
    swap [ 1.0name-char? ] [ 1.1name-char? ] if ;
