! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: concurrency.promises models tools.continuations kernel
sequences concurrency.messaging locals continuations
threads namespaces namespaces.private make assocs accessors
io strings prettyprint math words effects summary io.styles
classes ;
IN: tools.trace

: callstack-depth ( callstack -- n )
    callstack>array length ;

SYMBOL: end

SYMBOL: exclude-vocabs
SYMBOL: include-vocabs

exclude-vocabs { "kernel" "math" "accessors" } swap set-global

: include? ( vocab -- ? )
    include-vocabs get dup [ member? ] [ 2drop t ] if ;

: exclude? ( vocab -- ? )
    exclude-vocabs get dup [ member? ] [ 2drop f ] if ;

: into? ( obj -- ? )
    dup word? [
        dup predicate? [ drop f ] [
            vocabulary>> [ include? ] [ exclude? not ] bi and
        ] if
    ] [ drop t ] if ;

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

: trace-step ( continuation -- continuation' )
    dup continuation-current end eq? [
        [ call>> callstack-depth 2/ CHAR: \s <string> write ]
        [ print-step ]
        [
            dup continuation-current into?
            [ continuation-step-into ] [ continuation-step ] if
        ]
        tri
    ] unless ;

: trace ( quot -- data )
    [ [ trace-step ] break-hook ] dip
    [ break ] [ end drop ] surround
    with-variable ;
