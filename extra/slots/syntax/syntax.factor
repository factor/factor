! Copyright (C) 2010 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators combinators.smart fry lexer quotations
sequences slots  ;
IN: slots.syntax

SYNTAX: slots{
    "}" parse-tokens
    [ reader-word 1quotation ] map
    '[ [ _ cleave ] output>array ] append! ;