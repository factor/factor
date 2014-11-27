! Copyright (C) 2006 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors ascii assocs combinators fry hashtables io
io.streams.string json kernel math math.parser mirrors
namespaces sequences strings tr words ;
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
            { CHAR: \\  [ "\\\\" over stream-write ] }
            { CHAR: /  [ "\\/" over stream-write ] }
            { CHAR: \b [ "\\b" over stream-write ] }
            { CHAR: \f [ "\\f" over stream-write ] }
            { CHAR: \n [ "\\n" over stream-write ] }
            { CHAR: \r [ "\\r" over stream-write ] }
            { CHAR: \s [ "\\s" over stream-write ] }
            { CHAR: \t [ "\\t" over stream-write ] }
            [
                dup printable?
                [ over stream-write1 ]
                [
                    "\\u" pick stream-write
                    >hex 4 CHAR: 0 pad-head
                    over stream-write
                ] if
            ]
        } case
    ] each CHAR: " swap stream-write1 ;

M: integer stream-json-print
    [ number>string ] [ stream-write ] bi* ;

: float>json ( float -- string )
    {
        { [ dup fp-nan? ] [ drop "NaN" ] }
        { [ dup 1/0. = ] [ drop "Infinity" ] }
        { [ dup -1/0. = ] [ drop "-Infinity" ] }
        [ number>string ]
    } cond ;

M: float stream-json-print
    [ float>json ] [ stream-write ] bi* ;

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

GENERIC: >js-key ( obj -- str )
M: boolean >js-key "true" "false" ? ;
M: string >js-key jsvar-encode ;
M: number >js-key number>string ;
M: float >js-key float>json ;
M: json-null >js-key drop "null" ;

<PRIVATE

: json-print-assoc ( assoc stream -- )
    CHAR: { over stream-write1 swap >alist [
        jsvar-encode? get [
            over '[ CHAR: , _ stream-write1 ]
            pick dup '[
                first2
                [ >js-key _ stream-json-print ]
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
