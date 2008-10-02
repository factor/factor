USING: io kernel math math.functions math.parser parser lexer
namespaces make sequences splitting grouping combinators
continuations ;
IN: money

: dollars/cents ( dollars -- dollars cents )
    100 * 100 /mod round ;

: money>string ( object -- string )
    dollars/cents [
        "$" %
        swap number>string
        <reversed> 3 group "," join <reversed> %
        "." % number>string 2 CHAR: 0 pad-left %
    ] "" make ;

: money. ( object -- )
    money>string print ;

ERROR: not-a-decimal x ;

: parse-decimal ( str -- ratio )
    "." split1
    >r dup "-" head? [ drop t "0" ] [ f swap ] if r>
    [ [ "0" ] when-empty ] bi@
    dup length
    >r [ dup string>number [ nip ] [ not-a-decimal ] if* ] bi@ r>
    10 swap ^ / + swap [ neg ] when ;

: DECIMAL:
    scan parse-decimal parsed ; parsing
