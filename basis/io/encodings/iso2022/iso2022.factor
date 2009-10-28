! Copyright (C) 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: io.encodings kernel sequences io simple-flat-file sets math
combinators.short-circuit io.binary values arrays assocs
locals accessors combinators biassocs byte-arrays parser ;
IN: io.encodings.iso2022

SINGLETON: iso2022

<PRIVATE

VALUE: jis201
VALUE: jis208
VALUE: jis212

"vocab:io/encodings/iso2022/201.txt" flat-file>biassoc to: jis201
"vocab:io/encodings/iso2022/208.txt" flat-file>biassoc to: jis208
"vocab:io/encodings/iso2022/212.txt" flat-file>biassoc to: jis212

VALUE: ascii
128 unique >biassoc to: ascii

TUPLE: iso2022-state type ;

: make-iso-coder ( encoding -- state )
    drop ascii iso2022-state boa ;

M: iso2022 <encoder>
    make-iso-coder <encoder> ;

M: iso2022 <decoder>
    make-iso-coder <decoder> ;

<< SYNTAX: ESC HEX: 16 suffix! ; >>

CONSTANT: switch-ascii B{ ESC CHAR: ( CHAR: B }
CONSTANT: switch-jis201 B{ ESC CHAR: ( CHAR: J }
CONSTANT: switch-jis208 B{ ESC CHAR: $ CHAR: B }
CONSTANT: switch-jis212 B{ ESC CHAR: $ CHAR: ( CHAR: D }

: find-type ( char -- code type )
    {
        { [ dup ascii value? ] [ drop switch-ascii ascii ] }
        { [ dup jis201 value? ] [ drop switch-jis201 jis201 ] }
        { [ dup jis208 value? ] [ drop switch-jis208 jis208 ] }
        { [ dup jis212 value? ] [ drop switch-jis212 jis212 ] }
        [ encode-error ]
    } cond ;

: stream-write-num ( num stream -- )
    over 256 >=
    [ [ h>b/b swap 2byte-array ] dip stream-write ]
    [ stream-write1 ] if ;

M:: iso2022-state encode-char ( char stream encoding -- )
    char encoding type>> value? [
        char find-type
        [ stream stream-write ]
        [ encoding (>>type) ] bi*
    ] unless
    char encoding type>> value-at stream stream-write-num ;

: read-escape ( stream -- type/f )
    dup stream-read1 {
        { CHAR: ( [
            stream-read1 {
                { CHAR: B [ ascii ] }
                { CHAR: J [ jis201 ] }
                [ drop f ]
            } case
        ] }
        { CHAR: $ [
            dup stream-read1 {
                { CHAR: @ [ drop jis208 ] } ! want: JIS X 0208-1978 
                { CHAR: B [ drop jis208 ] }
                { CHAR: ( [
                    stream-read1 CHAR: D = jis212 f ?
                ] }
                [ 2drop f ]
            } case
        ] }
        [ 2drop f ]
    } case ;

: double-width? ( type -- ? )
    { [ jis208 eq? ] [ jis212 eq? ] } 1|| ;

: finish-decode ( num encoding -- char )
    type>> at replacement-char or ;

M:: iso2022-state decode-char ( stream encoding -- char )
    stream stream-read1 {
        { ESC [
            stream read-escape [
                encoding (>>type)
                stream encoding decode-char
            ] [ replacement-char ] if*
        ] }
        { f [ f ] }
        [
            encoding type>> double-width? [
                stream stream-read1
                [ 2byte-array be> encoding finish-decode ]
                [ drop replacement-char ] if*
            ] [ encoding finish-decode ] if
        ]
    } case ;
