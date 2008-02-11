USING: io kernel math math.functions math.parser parser
namespaces sequences splitting combinators continuations
sequences.lib ;
IN: money

: dollars/cents ( dollars -- dollars cents )
    100 * 100 /mod round ;

: money. ( object -- )
    dollars/cents
    [
        "$" %
        swap number>string
        <reversed> 3 group "," join <reversed> %
        "." % number>string 2 48 pad-left %
    ] "" make print ;

TUPLE: not-a-decimal ;
: DECIMAL:
    scan
    "." split dup length 1 2 between? [
        T{ not-a-decimal } throw
    ] unless
    ?first2
    >r dup ?first CHAR: - = [ drop t "0" ] [ f swap ] if r>
    [ dup empty? [ drop "0" ] when ] 2apply
    dup length
    >r [ string>number dup [ T{ not-a-decimal } throw ] unless ] 2apply r>
    10 swap ^ / + swap [ neg ] when parsed ; parsing
