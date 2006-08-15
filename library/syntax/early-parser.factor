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

TUPLE: check-vocab name ;
: check-vocab ( name -- vocab )
    dup vocab [ ] [
        <check-vocab>
        { { "Continue" f } } condition
    ] ?if ;

: use+ ( string -- ) check-vocab [ use get push ] when* ;

: add-use ( seq -- ) [ use+ ] each ;

: set-use ( seq -- )
    [ check-vocab ] map [ ] subset >vector use set ;

: set-in ( name -- ) dup ensure-vocab dup in set use+ ;

: parsing? ( word -- ? )
    dup word? [ "parsing" word-prop ] [ drop f ] if ;

: location ( -- loc ) file get line-number get 2array ;

: save-location ( word -- )
    dup set-word location "loc" set-word-prop ;

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

TUPLE: effect in out declarations terminated? ;

C: effect
    [
        over { "*" } sequence=
        [ nip t swap set-effect-terminated? ]
        [ set-effect-out ] if
    ] keep
    [ set-effect-in ] keep
    H{ } clone over set-effect-declarations ;

: effect-height ( effect -- n )
    dup effect-out length swap effect-in length - ;

: effect<= ( eff1 eff2 -- ? )
    2dup [ effect-terminated? ] 2apply = >r
    2dup [ effect-in length ] 2apply <= >r
    [ effect-height ] 2apply number= r> and r> and ;
