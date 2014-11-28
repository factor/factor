! Copyright (C) 2006 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors ascii assocs combinators fry hashtables io
io.streams.string json kernel locals math math.parser mirrors
namespaces sequences strings tr words ;
IN: json.writer

SYMBOL: json-allow-nans?
f json-allow-nans? set-global

SYMBOL: json-friendly-keys?
t json-friendly-keys? set-global

SYMBOL: json-coerce-keys?
t json-coerce-keys? set-global

SYMBOL: json-escape-slashes?
f json-escape-slashes? set-global

SYMBOL: json-escape-unicode?
f json-escape-unicode? set-global

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
            { CHAR: \\ [ "\\\\" over stream-write ] }
            { CHAR: /  [
                json-escape-slashes? get
                [ "\\/" over stream-write ]
                [ CHAR: / over stream-write1 ] if
            ] }
            { CHAR: \b [ "\\b" over stream-write ] }
            { CHAR: \f [ "\\f" over stream-write ] }
            { CHAR: \n [ "\\n" over stream-write ] }
            { CHAR: \r [ "\\r" over stream-write ] }
            { CHAR: \s [ "\\s" over stream-write ] }
            { CHAR: \t [ "\\t" over stream-write ] }
            { 0x2028   [ "\\u2028" over stream-write ] }
            { 0x2029   [ "\\u2029" over stream-write ] }
            [
                {
                    { [ dup printable? ] [ f ] }
                    { [ dup control? ] [ t ] }
                    [ json-escape-unicode? get ]
                } cond [
                    dup 0xffff > [ json-error ] when
                    "\\u" pick stream-write
                    >hex 4 CHAR: 0 pad-head
                    over stream-write
                ] [
                    over stream-write1
                ] if
            ]
        } case
    ] each CHAR: " swap stream-write1 ;

M: integer stream-json-print
    [ number>string ] [ stream-write ] bi* ;

: float>json ( float -- string )
    dup fp-special? [
        json-allow-nans? get [ json-error ] unless
        {
            { [ dup fp-nan? ] [ drop "NaN" ] }
            { [ dup 1/0. = ] [ drop "Infinity" ] }
            { [ dup -1/0. = ] [ drop "-Infinity" ] }
        } cond
    ] [
        number>string
    ] if ;

M: float stream-json-print
    [ float>json ] [ stream-write ] bi* ;

M: real stream-json-print
    [ >float number>string ] [ stream-write ] bi* ;

M: sequence stream-json-print
    CHAR: [ over stream-write1 swap
    over '[ CHAR: , _ stream-write1 ]
    pick '[ _ stream-json-print ] interleave
    CHAR: ] swap stream-write1 ;

<PRIVATE

TR: json-friendly "-" "_" ;

GENERIC: json-key ( obj -- str )
M: f json-key drop "false" ;
M: t json-key drop "true" ;
M: json-null json-key drop "null" ;
M: integer json-key number>string ;
M: float json-key float>json ;
M: real json-key >float number>string ;

:: json-print-assoc ( obj stream -- )
    CHAR: { stream stream-write1 obj >alist
    [ CHAR: , stream stream-write1 ]
    json-friendly-keys? get
    json-coerce-keys? get '[
        first2 [
            dup string?
            [ _ [ json-friendly ] when ]
            [ _ [ json-key ] when ] if
            stream stream-json-print
        ] [
            CHAR: : stream stream-write1
            stream stream-json-print
        ] bi*
    ] interleave
    CHAR: } stream stream-write1 ;

PRIVATE>

M: tuple stream-json-print
    [ <mirror> ] dip json-print-assoc ;

M: hashtable stream-json-print json-print-assoc ;

M: word stream-json-print
    [ name>> ] dip stream-json-print ;
