! Copyright (C) 2009 Jose Antonio Ortega Ruiz.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays continuations debugger fry fuel.pprint io
io.streams.string kernel listener namespaces parser.notes
prettyprint.config sequences sets vocabs.parser ;
IN: fuel.eval

SYMBOL: restarts-stack
V{ } clone restarts-stack set-global

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
    "<~FUEL~>" print flush ;

: begin-eval ( -- )
    push-status ;

: end-eval ( result error/f output -- )
    swapd send-retort pop-status ;

: eval ( lines -- result error/f )
    '[ _ parse-lines-interactive call( -- x ) f ]
    [ dup print-error f swap ] recover ;

: eval-usings ( usings -- )
    [ [ use-vocab ] curry ignore-errors ] each ;

: eval-in ( in -- )
    [ set-current-vocab ] when* ;

: eval-in-context ( lines in usings/f -- )
    begin-eval
    [
        parser-quiet? on
        [
            ! The idea is that a correct usings list should always be
            ! specified. But a lot of code in FUEL sends empty usings
            ! lists so then we have to use the current manifests
            ! vocabs instead.
            manifest get search-vocab-names>> members
        ] [
            ! These vocabs are always needed in the manifest. syntax for
            ! obvious reasons, fuel for FUEL stuff and debugger for the :N
            ! words.
            { "fuel" "syntax" "debugger" } prepend
        ] if-empty
        <manifest> manifest namespaces:set
        [ eval-usings eval-in eval ] with-string-writer
    ] with-scope end-eval ;
