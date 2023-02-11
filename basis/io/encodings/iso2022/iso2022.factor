! Copyright (C) 2009 Daniel Ehrenberg
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs biassocs byte-arrays combinators
combinators.short-circuit endian io io.encodings kernel
literals math math.bitwise namespaces sequences simple-flat-file ;
IN: io.encodings.iso2022

SINGLETON: iso2022

<PRIVATE

SYMBOL: jis201
SYMBOL: jis208
SYMBOL: jis212

"vocab:io/encodings/iso2022/201.txt" load-codetable-file jis201 set-global
"vocab:io/encodings/iso2022/208.txt" load-codetable-file jis208 set-global
"vocab:io/encodings/iso2022/212.txt" load-codetable-file jis212 set-global

SYMBOL: ascii
128 <iota> dup zip >biassoc ascii set-global

TUPLE: iso2022-state type ;

: make-iso-coder ( encoding -- state )
    drop ascii get-global iso2022-state boa ;

M: iso2022 <encoder>
    make-iso-coder <encoder> ;

M: iso2022 <decoder>
    make-iso-coder <decoder> ;

CONSTANT: ESC 0x16

CONSTANT: switch-ascii B{ $ ESC CHAR: ( CHAR: B }
CONSTANT: switch-jis201 B{ $ ESC CHAR: ( CHAR: J }
CONSTANT: switch-jis208 B{ $ ESC CHAR: $ CHAR: B }
CONSTANT: switch-jis212 B{ $ ESC CHAR: $ CHAR: ( CHAR: D }

: find-type ( char -- code type )
    {
        { [ dup ascii get-global value? ] [ drop switch-ascii ascii get-global ] }
        { [ dup jis201 get-global value? ] [ drop switch-jis201 jis201 get-global ] }
        { [ dup jis208 get-global value? ] [ drop switch-jis208 jis208 get-global ] }
        { [ dup jis212 get-global value? ] [ drop switch-jis212 jis212 get-global ] }
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
        [ encoding type<< ] bi*
    ] unless
    char encoding type>> value-at stream stream-write-num ;

: read-escape ( stream -- type/f )
    dup stream-read1 {
        { CHAR: ( [
            stream-read1 {
                { CHAR: B [ ascii get-global ] }
                { CHAR: J [ jis201 get-global ] }
                [ drop f ]
            } case
        ] }
        { CHAR: $ [
            dup stream-read1 {
                { CHAR: @ [ drop jis208 get-global ] } ! want: JIS X 0208-1978
                { CHAR: B [ drop jis208 get-global ] }
                { CHAR: ( [
                    stream-read1 CHAR: D = jis212 get-global f ?
                ] }
                [ 2drop f ]
            } case
        ] }
        [ 2drop f ]
    } case ;

: double-width? ( type -- ? )
    { [ jis208 get-global eq? ] [ jis212 get-global eq? ] } 1|| ;

: finish-decode ( num encoding -- char )
    type>> at replacement-char or ;

M:: iso2022-state decode-char ( stream encoding -- char )
    stream stream-read1 {
        { $ ESC [
            stream read-escape [
                encoding type<<
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

PRIVATE>
