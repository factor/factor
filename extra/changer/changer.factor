! Copyright (C) 2015 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: fry kernel lexer macros quotations sequences words ;
IN: changer

MACRO: inline-changer ( name -- quot' )
    [ ">>" append ] [ ">>" prepend ] bi
    [ "accessors" lookup-word 1quotation ] bi@
    '[ over [ _ dip call ] dip swap @ ] ;

SYNTAX: change: scan-token '[ _ inline-changer ] append! ;
