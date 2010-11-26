! Copyright (C) 2010 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators combinators.smart fry kernel lexer
quotations sequences sequences.generalizations slots words ;
IN: slots.syntax

SYNTAX: slots[
    "]" [ reader-word 1quotation ] map-tokens
    '[ _ cleave ] append! ;

SYNTAX: slots{
    "}" [ reader-word 1quotation ] map-tokens
    '[ [ _ cleave ] output>array ] append! ;

: writer-word* ( name -- word )
    ">>" prepend "accessors" lookup ;

SYNTAX: set-slots[
    "]" [ writer-word* 1quotation ] map-tokens
    '[ _ spread ] append! ;

SYNTAX: set-slots{
    "}" [ writer-word* 1quotation ] map-tokens
    [ length ] [ ] bi
    '[ _ firstn _ spread ] append! ;
