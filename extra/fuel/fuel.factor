! Copyright (C) 2008 Jose Antonio Ortega Ruiz.
! See http://factorcode.org/license.txt for BSD license.

USING: accessors arrays classes classes.tuple compiler.units
combinators continuations debugger definitions eval help
io io.files io.streams.string kernel lexer listener listener.private
make math namespaces parser prettyprint prettyprint.config
quotations sequences strings source-files vectors vocabs.loader ;

IN: fuel

! Evaluation status:

TUPLE: fuel-status in use ds? restarts ;

SYMBOL: fuel-status-stack
V{ } clone fuel-status-stack set-global

SYMBOL: fuel-eval-result
f clone fuel-eval-result set-global

SYMBOL: fuel-eval-output
f clone fuel-eval-result set-global

SYMBOL: fuel-eval-res-flag
t clone fuel-eval-res-flag set-global

: fuel-eval-restartable? ( -- ? )
    fuel-eval-res-flag get-global ; inline

: fuel-eval-restartable ( -- )
    t fuel-eval-res-flag set-global ; inline

: fuel-eval-non-restartable ( -- )
    f fuel-eval-res-flag set-global ; inline

: push-fuel-status ( -- )
    in get use get clone display-stacks? get restarts get-global clone
    fuel-status boa
    fuel-status-stack get push ;

: pop-fuel-status ( -- )
    fuel-status-stack get empty? [
        fuel-status-stack get pop {
            [ in>> in set ]
            [ use>> clone use set ]
            [ ds?>> display-stacks? swap [ on ] [ off ] if ]
            [
                restarts>> fuel-eval-restartable? [ drop ] [
                    clone restarts set-global
                ] if
            ]
        } cleave
    ] unless ;


! Lispy pretty printing

GENERIC: fuel-pprint ( obj -- )

M: object fuel-pprint pprint ; inline

M: f fuel-pprint drop "nil" write ; inline

M: integer fuel-pprint pprint ; inline

M: string fuel-pprint pprint ; inline

M: sequence fuel-pprint
    dup empty? [ drop f fuel-pprint ] [
        "(" write
        [ " " write ] [ fuel-pprint ] interleave
        ")" write
    ] if ;

M: tuple fuel-pprint tuple>array fuel-pprint ; inline

M: continuation fuel-pprint drop ":continuation" write ; inline

M: restart fuel-pprint name>> fuel-pprint ; inline

SYMBOL: :restarts

: fuel-restarts ( obj -- seq )
    compute-restarts :restarts prefix ; inline

M: condition fuel-pprint
    [ error>> ] [ fuel-restarts ] bi 2array condition prefix fuel-pprint ;

M: source-file-error fuel-pprint
    [ file>> ] [ error>> ] bi 2array source-file-error prefix
    fuel-pprint ;

M: source-file fuel-pprint path>> fuel-pprint ;

! Evaluation vocabulary

: fuel-eval-set-result ( obj -- )
    clone fuel-eval-result set-global ; inline

: fuel-retort ( -- )
    error get
    fuel-eval-result get-global
    fuel-eval-output get-global
    3array fuel-pprint ;

: fuel-forget-error ( -- ) f error set-global ; inline
: fuel-forget-result ( -- ) f fuel-eval-result set-global ; inline
: fuel-forget-output ( -- ) f fuel-eval-output set-global ; inline

: (fuel-begin-eval) ( -- )
    push-fuel-status
    display-stacks? off
    fuel-forget-error
    fuel-forget-result
    fuel-forget-output ;

: (fuel-end-eval) ( quot -- )
    with-string-writer fuel-eval-output set-global
    fuel-retort pop-fuel-status ; inline

: (fuel-eval) ( lines -- )
    [ [ parse-lines ] with-compilation-unit call ] curry
    [ print-error ] recover ; inline

: (fuel-eval-each) ( lines -- )
    [ 1vector (fuel-eval) ] each ; inline

: (fuel-eval-usings) ( usings -- )
    [ "USING: " prepend " ;" append ] map
    (fuel-eval-each) fuel-forget-error fuel-forget-output ;

: (fuel-eval-in) ( in -- )
    [ dup "IN: " prepend 1vector (fuel-eval) in set ] when* ; inline

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
    (fuel-begin-eval) [ (fuel-eval) ] (fuel-end-eval) ; inline

: fuel-end-eval ( -- ) [ ] (fuel-end-eval) ; inline

: fuel-get-edit-location ( defspec -- )
    where [ first2 [ (normalize-path) ] dip 2array fuel-eval-set-result ]
    when* ;

: fuel-run-file ( path -- ) run-file ; inline

: fuel-startup ( -- ) "listener" run ; inline

MAIN: fuel-startup
