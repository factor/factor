! Copyright (C) 2009 Jose Antonio Ortega Ruiz.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays continuations debugger fuel.pprint io io.streams.string
kernel listener namespaces parser.notes prettyprint.config sequences
vocabs.parser ;
IN: fuel.eval

SYMBOL: restarts-stack
V{ } clone restarts-stack set-global

SYMBOL: eval-result
f eval-result set-global

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

: send-retort ( error result output -- )
    3array [ fuel-pprint ] without-limits flush nl
    "<~FUEL~>" write nl flush ;

: begin-eval ( -- )
    f eval-result set-global push-status ;

: end-eval ( error/f output -- )
    eval-result get-global swap send-retort pop-status ;

: eval ( lines -- error/f )
    [ parse-lines-interactive call( -- ) f ] curry
    [ dup print-error ] recover ;

: eval-usings ( usings -- )
    [ [ use-vocab ] curry ignore-errors ] each ;

: eval-in ( in -- )
    [ set-current-vocab ] when* ;

: eval-in-context ( lines in usings -- )
    begin-eval
    [
        parser-quiet? on
        ! These vocabs are always needed in the manifest. syntax for
        ! obvious reasons, fuel for FUEL stuff and debugger for the :N
        ! words.
        { "fuel" "syntax" "debugger" } prepend
        <manifest> manifest set
        [ eval-usings eval-in eval ] with-string-writer
    ] with-scope end-eval ;
