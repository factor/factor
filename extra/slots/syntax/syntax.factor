! Copyright (C) 2010 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators combinators.smart fry lexer quotations
sequences slots  ;
IN: slots.syntax

SYNTAX: slots[
    "]" [ reader-word 1quotation ] map-tokens
    '[ _ cleave ] append! ;

SYNTAX: slots{
    "}" [ reader-word 1quotation ] map-tokens
    '[ [ _ cleave ] output>array ] append! ;
