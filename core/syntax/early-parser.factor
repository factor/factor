! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: parser
USING: arrays errors generic hashtables kernel math namespaces
sequences strings vectors words ;

SYMBOL: use
SYMBOL: in

SYMBOL: file
SYMBOL: line-number

SYMBOL: line-text
SYMBOL: column-number

TUPLE: check-vocab name ;
: check-vocab ( name -- vocab )
    dup vocab [ ] [
        <check-vocab>
        { { "Continue" f } } condition
    ] ?if ;

: use+ ( vocab -- ) check-vocab [ use get push ] when* ;

: add-use ( seq -- ) [ use+ ] each ;

: set-use ( seq -- )
    [ check-vocab ] map [ ] subset >vector use set ;

: set-in ( name -- )
    dup string?
    [ "Vocabulary name must be a string" throw ] unless
    dup ensure-vocab dup in set use+ ;

: parsing? ( obj -- ? )
    dup word? [ "parsing" word-prop ] [ drop f ] if ;

: location ( -- loc )
    file get line-number get 2dup and
    [ 2array ] [ 2drop f ] if ;

: save-location ( word -- )
    dup set-word location "loc" set-word-prop ;

: create-in ( string -- word )
    in get create dup save-location ;

: create-constructor ( class -- word )
    word-name in get constructor-word dup save-location ;

TUPLE: parse-error file line col text ;

C: parse-error ( msg -- error )
    file get over set-parse-error-file
    line-number get over set-parse-error-line
    column-number get over set-parse-error-col
    line-text get over set-parse-error-text
    [ set-delegate ] keep ;
