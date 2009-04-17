! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: concurrency.promises models tools.continuations kernel
sequences concurrency.messaging locals continuations threads
namespaces namespaces.private make assocs accessors io strings
prettyprint math math.parser words effects summary io.styles classes
generic.math combinators.short-circuit ;
IN: tools.trace

: callstack-depth ( callstack -- n )
    callstack>array length 2/ ;

SYMBOL: end

SYMBOL: exclude-vocabs
SYMBOL: include-vocabs

exclude-vocabs { "math" "accessors" } swap set-global

: include? ( vocab -- ? )
    include-vocabs get dup [ member? ] [ 2drop t ] if ;

: exclude? ( vocab -- ? )
    exclude-vocabs get dup [ member? ] [ 2drop f ] if ;

: into? ( obj -- ? )
    {
        [ word? ]
        [ predicate? not ]
        [ math-generic? not ]
        [
            {
                [ inline? ]
                [
                    {
                        [ vocabulary>> include? ]
                        [ vocabulary>> exclude? not ]
                    } 1&&
                ]
            } 1||
        ]
    } 1&& ;

TUPLE: trace-step word inputs ;

M: trace-step summary
    [
        [ "Word: " % word>> name>> % ]
        [ " -- inputs: " % inputs>> unparse-short % ] bi
    ] "" make ;

: <trace-step> ( continuation word -- trace-step )
    [ nip ] [ [ data>> ] [ stack-effect in>> length ] bi* short tail* ] 2bi
    \ trace-step boa ;

: print-step ( continuation -- )
    dup continuation-current dup word? [
        [ nip name>> ] [ <trace-step> ] 2bi write-object nl
    ] [
        nip short.
    ] if ;

: print-depth ( continuation -- )
    call>> callstack-depth
    [ CHAR: \s <string> write ]
    [ number>string write ": " write ] bi ;

: trace-step ( continuation -- continuation' )
    dup continuation-current end eq? [
        [ print-depth ]
        [ print-step ]
        [
            dup continuation-current into?
            [ continuation-step-into ] [ continuation-step ] if
        ] tri
    ] unless ;

: trace ( quot -- data )
    [ [ trace-step ] break-hook ] dip
    [ break ] [ end drop ] surround
    with-variable ;

<< \ trace t "no-compile" set-word-prop >>