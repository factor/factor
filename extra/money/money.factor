USING: io kernel math math.functions math.parser parser
namespaces sequences splitting grouping combinators
continuations sequences.lib ;
IN: money

: dollars/cents ( dollars -- dollars cents )
    100 * 100 /mod round ;

: money. ( object -- )
    dollars/cents
    [
        "$" %
        swap number>string
        <reversed> 3 group "," join <reversed> %
        "." % number>string 2 CHAR: 0 pad-left %
    ] "" make print ;

ERROR: not-a-decimal x ;

: parse-decimal ( str -- ratio )
    "." split1
    >r dup "-" head? [ drop t "0" ] [ f swap ] if r>
    [ dup empty? [ drop "0" ] when ] bi@
    dup length
    >r [ dup string>number [ nip ] [ not-a-decimal ] if* ] bi@ r>
    10 swap ^ / + swap [ neg ] when ;

: DECIMAL:
    scan parse-decimal parsed ; parsing
