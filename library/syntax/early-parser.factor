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
SYMBOL: column

: check-vocab ( name -- vocab )
    dup vocab [ ] [
        "No such vocabulary: " swap >string append throw
    ] ?if ;

: use+ ( string -- ) check-vocab use get push ;

: add-use ( seq -- ) [ use+ ] each ;

: set-use ( seq -- ) [ check-vocab ] map >vector use set ;

: set-in ( name -- ) dup ensure-vocab dup in set use+ ;

: parsing? ( word -- ? )
    dup word? [ "parsing" word-prop ] [ drop f ] if ;

: save-location ( word -- )
    dup set-word
    dup line-number get "line" set-word-prop
    file get "file" set-word-prop ;

: create-in in get create dup save-location ;

: create-constructor ( class -- word )
    word-name in get constructor-word dup save-location ;

TUPLE: parse-error file line col text ;

C: parse-error ( error -- error )
    file get over set-parse-error-file
    line-number get over set-parse-error-line
    column get over set-parse-error-col
    line-text get over set-parse-error-text
    [ set-delegate ] keep ;
