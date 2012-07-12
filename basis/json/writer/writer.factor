! Copyright (C) 2006 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel io.streams.string io strings splitting
sequences math math.parser assocs classes words namespaces make
prettyprint hashtables mirrors tr json fry combinators ;
IN: json.writer

#! Writes the object out to a stream in JSON format
GENERIC: json-print ( obj -- )

: >json ( obj -- string )
    #! Returns a string representing the factor object in JSON format
    [ json-print ] with-string-writer ;

M: f json-print ( f -- )
    drop "false" write ;

M: t json-print ( t -- )
    drop "true" write ;

M: json-null json-print ( null -- )
    drop "null" write ;

M: string json-print ( obj -- )
    CHAR: " write1 [
        {
            { CHAR: "  [ "\\\"" write ] }
            { CHAR: \r [ ] }
            { CHAR: \n [ "\\r\\n" write ] }
            [ write1 ]
        } case
    ] each CHAR: " write1 ;

M: integer json-print ( num -- )
    number>string write ;

M: real json-print ( num -- )
    >float number>string write ;

M: sequence json-print ( array -- )
    CHAR: [ write1 [
        unclip-last-slice swap
        [ json-print CHAR: , write1 ] each
        json-print
    ] unless-empty CHAR: ] write1 ;

SYMBOL: jsvar-encode?
t jsvar-encode? set-global
TR: jsvar-encode "-" "_" ;

<PRIVATE

: json-print-assoc ( assoc -- )
    CHAR: { write1 >alist [
        unclip-last-slice swap
        jsvar-encode? get [
            [
                [ first jsvar-encode json-print ]
                [ CHAR: : write1 second json-print ] bi
                CHAR: , write1
            ] each
            [ first jsvar-encode json-print ]
            [ CHAR: : write1 second json-print ] bi
        ] [
            [
                [ first json-print ]
                [ CHAR: : write1 second json-print ] bi
                CHAR: , write1
            ] each
            [ first json-print ]
            [ CHAR: : write1 second json-print ] bi
        ] if
    ] unless-empty CHAR: } write1 ;

PRIVATE>

M: tuple json-print ( tuple -- ) <mirror> json-print-assoc ;

M: hashtable json-print ( hashtable -- ) json-print-assoc ;

M: word json-print name>> json-print ;
