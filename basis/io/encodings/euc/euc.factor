! Copyright (C) 2009 Daniel Ehrenberg, Jonghyouk Yun.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel io.encodings accessors assocs sequences biassocs generic
math.order simple-flat-file io io.binary byte-arrays locals combinators
words classes.singleton fry classes.parser parser quotations ;
IN: io.encodings.euc

TUPLE: euc { table biassoc read-only } ;

<PRIVATE

: byte? ( ch -- ? )
    0x0 0xff between? ;

M: euc encode-char ( char stream encoding -- )
    swapd table>> value-at [
        dup byte?
        [ swap stream-write1 ] [
            h>b/b swap 2byte-array
            swap stream-write
        ] if
    ] [ encode-error ] if* ;

: euc-multibyte? ( ch -- ? )
    0x81 0xfe between? ;

:: decode-multibyte ( ch stream encoding -- char )
    stream stream-read1
    [ ch swap 2byte-array be> encoding table>> at ]
    [ replacement-char ] if* ;

M:: euc decode-char ( stream encoding -- char/f )
    stream stream-read1
    {
        { [ dup not ] [ drop f ] }
        { [ dup euc-multibyte? ] [ stream encoding decode-multibyte ] }
        [ encoding table>> at ]
    } cond ;

: define-method ( class word definition -- )
    [ create-method ] dip define ;

SYMBOL: euc-table

: setup-euc ( word file-name -- singleton-class biassoc )
    [ dup define-singleton-class ]
    [ load-codetable-file ] bi* ;

:: define-recursive-methods ( class data words -- )
    words [| word |
        class word [ drop data word execute ] define-method
    ] each ;

: euc-methods ( singleton-class biassoc -- )
    [ euc-table set-word-prop ] [
        euc boa
        { <encoder> <decoder> }
        define-recursive-methods
    ] 2bi ;

: define-euc ( word file-name -- )
    setup-euc euc-methods ;

PRIVATE>

SYNTAX: EUC:
    ! EUC: euc-kr "vocab:io/encodings/korean/cp949.txt"
    scan-new-class scan-object define-euc ;
