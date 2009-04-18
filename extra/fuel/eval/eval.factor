! Copyright (C) 2009 Jose Antonio Ortega Ruiz.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays compiler.units continuations debugger
fuel.pprint io io.streams.string kernel namespaces parser sequences
vectors vocabs.parser ;

IN: fuel.eval

TUPLE: fuel-status in use restarts ;

SYMBOL: fuel-status-stack
V{ } clone fuel-status-stack set-global

SYMBOL: fuel-eval-result
f fuel-eval-result set-global

SYMBOL: fuel-eval-output
f fuel-eval-result set-global

SYMBOL: fuel-eval-res-flag
t fuel-eval-res-flag set-global

: fuel-eval-restartable? ( -- ? )
    fuel-eval-res-flag get-global ;

: fuel-push-status ( -- )
    in get use get clone restarts get-global clone
    fuel-status boa
    fuel-status-stack get push ;

: fuel-pop-restarts ( restarts -- )
    fuel-eval-restartable? [ drop ] [ clone restarts set-global ] if ;

: fuel-pop-status ( -- )
    fuel-status-stack get empty? [
        fuel-status-stack get pop
        [ in>> in set ]
        [ use>> clone use set ]
        [ restarts>> fuel-pop-restarts ] tri
    ] unless ;

: fuel-forget-error ( -- ) f error set-global ;
: fuel-forget-result ( -- ) f fuel-eval-result set-global ;
: fuel-forget-output ( -- ) f fuel-eval-output set-global ;
: fuel-forget-status ( -- )
    fuel-forget-error fuel-forget-result fuel-forget-output ;

: fuel-send-retort ( -- )
    error get fuel-eval-result get-global fuel-eval-output get-global
    3array fuel-pprint flush nl "<~FUEL~>" write nl flush ;

: (fuel-begin-eval) ( -- )
    fuel-push-status fuel-forget-status ;

: (fuel-end-eval) ( output -- )
    fuel-eval-output set-global fuel-send-retort fuel-pop-status ;

: (fuel-eval) ( lines -- )
    [ [ parse-lines ] with-compilation-unit call( -- ) ] curry
    [ print-error ] recover ;

: (fuel-eval-each) ( lines -- )
    [ (fuel-eval) ] each ;

: (fuel-eval-usings) ( usings -- )
    [ "USE: " prepend ] map
    (fuel-eval-each) fuel-forget-error fuel-forget-output ;

: (fuel-eval-in) ( in -- )
    [ dup "IN: " prepend (fuel-eval) in set ] when* ;

: (fuel-eval-in-context) ( lines in usings -- )
    (fuel-begin-eval)
    [ (fuel-eval-usings) (fuel-eval-in) "\n" join (fuel-eval) ] with-string-writer
    (fuel-end-eval) ;
