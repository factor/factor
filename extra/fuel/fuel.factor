! Copyright (C) 2008 Jose Antonio Ortega Ruiz.
! See http://factorcode.org/license.txt for BSD license.

USING: accessors arrays classes.tuple compiler.units continuations debugger
eval io io.streams.string kernel listener listener.private
make math namespaces parser prettyprint quotations sequences strings
vectors vocabs.loader ;

IN: fuel

! <PRIVATE

TUPLE: fuel-status in use ds? ;

SYMBOL: fuel-status-stack
V{ } clone fuel-status-stack set-global

: push-fuel-status ( -- )
    in get use get clone display-stacks? get
    fuel-status boa
    fuel-status-stack get push ;

: pop-fuel-status ( -- )
    fuel-status-stack get empty? [
        fuel-status-stack get pop
        [ in>> in set ]
        [ use>> clone use set ]
        [ ds?>> display-stacks? swap [ on ] [ off ] if ] tri
    ] unless ;

SYMBOL: fuel-eval-result
f clone fuel-eval-result set-global

SYMBOL: fuel-eval-output
f clone fuel-eval-result set-global

! PRIVATE>

GENERIC: fuel-pprint ( obj -- )

M: object fuel-pprint pprint ;

M: f fuel-pprint drop "nil" write ;

M: integer fuel-pprint pprint ;

M: string fuel-pprint pprint ;

M: sequence fuel-pprint
    dup empty? [ drop f fuel-pprint ] [
        "(" write
        [ " " write ] [ fuel-pprint ] interleave
        ")" write
    ] if ;

M: tuple fuel-pprint tuple>array fuel-pprint ;

M: continuation fuel-pprint drop "~continuation~" write ;

: fuel-eval-set-result ( obj -- )
    clone fuel-eval-result set-global ;

: fuel-retort ( -- )
    error get
    fuel-eval-result get-global
    fuel-eval-output get-global
    3array fuel-pprint ;

: fuel-forget-error ( -- )
    f error set-global ;

: (fuel-begin-eval) ( -- )
    push-fuel-status
    display-stacks? off
    fuel-forget-error
    f fuel-eval-result set-global
    f fuel-eval-output set-global ;

: (fuel-end-eval) ( quot -- )
    with-string-writer fuel-eval-output set-global
    fuel-retort
    pop-fuel-status ;

: (fuel-eval) ( lines -- )
    [ [ parse-lines ] with-compilation-unit call ] curry [ drop ] recover ;

: (fuel-eval-each) ( lines -- )
    [ 1vector (fuel-eval) ] each ;

: (fuel-eval-usings) ( usings -- )
    [ "USING: " prepend " ;" append ] map
    (fuel-eval-each) fuel-forget-error ;

: (fuel-eval-in) ( in -- )
    [ dup "IN: " prepend 1vector (fuel-eval) in set ] when* ;

: fuel-eval-in-context ( lines in usings -- )
    (fuel-begin-eval) [
        (fuel-eval-usings)
        (fuel-eval-in)
        (fuel-eval)
    ] (fuel-end-eval) ;

: fuel-begin-eval ( in -- )
    (fuel-begin-eval)
    (fuel-eval-in)
    fuel-retort ;

: fuel-eval ( lines -- )
    (fuel-begin-eval) [ (fuel-eval) ] (fuel-end-eval) ;

: fuel-end-eval ( -- )
    [ ] (fuel-end-eval) ;


: fuel-startup ( -- )
    "listener" run ;

MAIN: fuel-startup
