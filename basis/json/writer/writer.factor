! Copyright (C) 2006 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel io.streams.string io strings splitting
sequences math math.parser assocs classes words namespaces make
prettyprint hashtables mirrors tr json fry combinators ;
IN: json.writer

#! Writes the object out to a stream in JSON format
GENERIC# stream-json-print 1 ( obj stream -- )

: json-print ( obj -- )
    output-stream get stream-json-print ;

: >json ( obj -- string )
    #! Returns a string representing the factor object in JSON format
    [ json-print ] with-string-writer ;

M: f stream-json-print
    [ drop "false" ] [ stream-write ] bi* ;

M: t stream-json-print
    [ drop "true" ] [ stream-write ] bi* ;

M: json-null stream-json-print
    [ drop "null" ] [ stream-write ] bi* ;

M: string stream-json-print
    CHAR: " over stream-write1 swap [
        {
            { CHAR: "  [ "\\\"" over stream-write ] }
            { CHAR: \r [ ] }
            { CHAR: \n [ "\\r\\n" over stream-write ] }
            [ over stream-write1 ]
        } case
    ] each CHAR: " swap stream-write1 ;

M: integer stream-json-print
    [ number>string ] [ stream-write ] bi* ;

M: real stream-json-print
    [ >float number>string ] [ stream-write ] bi* ;

M: sequence stream-json-print
    CHAR: [ over stream-write1 swap [
        over '[ CHAR: , _ stream-write1 ]
        pick '[ _ stream-json-print ] interleave
    ] unless-empty CHAR: ] swap stream-write1 ;

SYMBOL: jsvar-encode?
t jsvar-encode? set-global
TR: jsvar-encode "-" "_" ;

<PRIVATE

: json-print-assoc ( assoc stream -- )
    CHAR: { over stream-write1 swap >alist [
        jsvar-encode? get [
            over '[ CHAR: , _ stream-write1 ]
            pick dup '[
                first2
                [ jsvar-encode _ stream-json-print ]
                [ _ CHAR: : over stream-write1 stream-json-print ]
                bi*
            ] interleave
        ] [
            over '[ CHAR: , _ stream-write1 ]
            pick dup '[
                first2
                [ _ stream-json-print ]
                [ _ CHAR: : over stream-write1 stream-json-print ]
                bi*
            ] interleave
        ] if
    ] unless-empty CHAR: } swap stream-write1 ;

PRIVATE>

M: tuple stream-json-print
    [ <mirror> ] dip json-print-assoc ;

M: hashtable stream-json-print json-print-assoc ;

M: word stream-json-print
    [ name>> ] dip stream-json-print ;
