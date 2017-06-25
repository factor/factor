! Copyright (C) 2009 Jose Antonio Ortega Ruiz.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays continuations debugger fuel.pprint io io.streams.string
kernel listener namespaces prettyprint.config sequences vocabs.parser
;
IN: fuel.eval

SYMBOL: restarts-stack
V{ } clone restarts-stack set-global

SYMBOL: eval-error
f eval-error set-global

SYMBOL: eval-result
f eval-result set-global

SYMBOL: eval-output
f eval-output set-global

SYMBOL: eval-res-flag
t eval-res-flag set-global

: eval-restartable? ( -- ? )
    eval-res-flag get-global ;

: push-status ( -- )
    restarts get-global clone restarts-stack get push ;

: pop-restarts ( restarts -- )
    eval-restartable? [ drop ] [ clone restarts set-global ] if ;

: pop-status ( -- )
    restarts-stack get [ pop pop-restarts ] unless-empty ;

: send-retort ( -- )
    eval-error get-global
    eval-result get-global
    eval-output get-global 3array
    [ fuel-pprint ] without-limits
    flush nl "<~FUEL~>" write nl flush ;

: begin-eval ( -- )
    push-status
    f eval-error set-global
    f eval-result set-global
    f eval-output set-global ;

: end-eval ( output -- )
    eval-output set-global send-retort pop-status ;

: eval ( lines -- )
    [ parse-lines-interactive call( -- ) ] curry
    [ [ eval-error set-global ] [ print-error ] bi ] recover ;

: eval-usings ( usings -- )
    [ [ use-vocab ] curry ignore-errors ] each ;

: eval-in ( in -- )
    [ set-current-vocab ] when* ;

: eval-in-context ( lines in usings -- )
    begin-eval
    [
        { "fuel" "syntax" } prepend
        <manifest> manifest set
        [ eval-usings eval-in eval ] with-string-writer
    ] with-scope end-eval ;
