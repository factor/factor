USING: io kernel math math.functions math.parser parser lexer
namespaces make sequences splitting grouping combinators
continuations ;
IN: money

SYMBOL: currency-token
CHAR: $ \ currency-token set-global

: dollars/cents ( dollars -- dollars cents )
    100 * 100 /mod round ;

: (money>string) ( dollars cents -- string )
    [ number>string ] bi@
    [ <reversed> 3 group "," join <reversed> ]
    [ 2 CHAR: 0 pad-head ] bi* "." glue ;

: money>string ( object -- string )
    dollars/cents (money>string) currency-token get prefix ;

: money. ( object -- ) money>string print ;

ERROR: not-an-integer x ;

: parse-decimal ( str -- ratio )
    "." split1
    [ "-" ?head swap ] dip
    [ [ "0" ] when-empty ] bi@
    [
        [ dup string>number [ nip ] [ not-an-integer ] if* ] bi@
    ] keep length
    10^ / + swap [ neg ] when ;

SYNTAX: DECIMAL: scan parse-decimal suffix! ;
