! Copyright (C) 2010 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: combinators combinators.smart kernel lexer quotations
sequences sequences.generalizations slots words ;
IN: slots.syntax

SYNTAX: slots[
    "]" [ reader-word 1quotation ] map-tokens
    '[ _ cleave ] append! ;

SYNTAX: slots{
    "}" [ reader-word 1quotation ] map-tokens
    '[ _ cleave>array ] append! ;

: >>writer-word ( name -- word )
    ">>" prepend "accessors" lookup-word ;

: writer-word<< ( name -- word )
    ">>" prepend "accessors" lookup-word ;

SYNTAX: set-slots[
    "]" [ >>writer-word 1quotation ] map-tokens
    '[ _ spread ] append! ;

SYNTAX: set-slots{
    "}" [ >>writer-word 1quotation ] map-tokens
    [ length ] [ ] bi
    '[ _ firstn _ spread ] append! ;

SYNTAX: copy-slots{
    "}" [
        [ reader-word 1quotation ]
        [ writer-word<< 1quotation ] bi append
    ] map-tokens
    '[ swap _ cleave ] append! ;

SYNTAX: get[ POSTPONE: slots[ ;
SYNTAX: get{ POSTPONE: slots{ ;
SYNTAX: set[ POSTPONE: set-slots[ ;
SYNTAX: set{ POSTPONE: set-slots{ ;
