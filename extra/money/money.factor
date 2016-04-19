! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: grouping io kernel lexer math math.functions math.parser
namespaces sequences splitting ;
IN: money

SYMBOL: currency-token
CHAR: $ currency-token set-global

: dollars/cents ( dollars -- dollars cents )
    100 * 100 /mod round ;

: format-money ( dollars cents -- string )
    [ number>string ] bi@
    [ <reversed> 3 group "," join <reversed> ]
    [ 2 CHAR: 0 pad-head ] bi* "." glue ;

: money>string ( number -- string )
    dollars/cents format-money currency-token get prefix ;

: money. ( number -- ) money>string print ;

ERROR: not-an-integer x ;

: split-decimal ( str -- neg? dollars cents )
    "." split1 [ "-" ?head swap ] dip ;

: parse-decimal ( str -- ratio )
    split-decimal [ [ "0" ] when-empty ] bi@
    [
        [ dup string>number [ nip ] [ not-an-integer ] if* ] bi@
    ] keep length 10^ / + swap [ neg ] when ;

SYNTAX: DECIMAL: scan-token parse-decimal suffix! ;
