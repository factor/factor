! Copyright (C) 2009 Jose Antonio Ortega Ruiz.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays continuations debugger fuel.pprint io
io.streams.string kernel listener namespaces prettyprint.config sequences
vocabs.parser ;

IN: fuel.eval

TUPLE: fuel-status manifest restarts ;

SYMBOL: fuel-status-stack
V{ } clone fuel-status-stack set-global

SYMBOL: fuel-eval-error
f fuel-eval-error set-global

SYMBOL: fuel-eval-result
f fuel-eval-result set-global

SYMBOL: fuel-eval-output
f fuel-eval-result set-global

SYMBOL: fuel-eval-res-flag
t fuel-eval-res-flag set-global

: fuel-eval-restartable? ( -- ? )
    fuel-eval-res-flag get-global ;

: fuel-push-status ( -- )
    manifest get clone restarts get-global clone
    fuel-status boa
    fuel-status-stack get push ;

: fuel-pop-restarts ( restarts -- )
    fuel-eval-restartable? [ drop ] [ clone restarts set-global ] if ;

: fuel-pop-status ( -- )
    fuel-status-stack get [
        pop
        [ manifest>> clone manifest set ]
        [ restarts>> fuel-pop-restarts ]
        bi
    ] unless-empty ;

: fuel-forget-error ( -- ) f fuel-eval-error set-global ;
: fuel-forget-result ( -- ) f fuel-eval-result set-global ;
: fuel-forget-output ( -- ) f fuel-eval-output set-global ;
: fuel-forget-status ( -- )
    fuel-forget-error fuel-forget-result fuel-forget-output ;

: fuel-send-retort ( -- )
    fuel-eval-error get-global
    fuel-eval-result get-global
    fuel-eval-output get-global 3array
    [ fuel-pprint ] without-limits
    flush nl "<~FUEL~>" write nl flush ;

: (fuel-begin-eval) ( -- )
    fuel-push-status fuel-forget-status ;

: (fuel-end-eval) ( output -- )
    fuel-eval-output set-global fuel-send-retort fuel-pop-status ;

: (fuel-eval) ( lines -- )
    [ parse-lines-interactive call( -- ) ] curry
    [ [ fuel-eval-error set-global ] [ print-error ] bi ] recover ;

: (fuel-eval-usings) ( usings -- )
    [ [ use-vocab ] curry [ drop ] recover ] each ;

: (fuel-eval-in) ( in -- )
    [ set-current-vocab ] when* ;

: (fuel-eval-in-context) ( lines in usings -- )
    (fuel-begin-eval)
    [ (fuel-eval-usings) (fuel-eval-in) (fuel-eval) ] with-string-writer
    (fuel-end-eval) ;
