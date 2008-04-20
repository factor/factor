USING: math kernel slots.private inference.known-words
inference.backend sequences effects words ;
IN: locals.backend

: load-locals ( n -- )
    dup zero? [ drop ] [ swap >r 1- load-locals ] if ;

: get-local ( n -- value )
    dup zero? [ drop dup ] [ r> swap 1- get-local swap >r ] if ;

: local-value 2 slot ; inline

: set-local-value 2 set-slot ; inline

: drop-locals ( n -- )
    dup zero? [ drop ] [ r> drop 1- drop-locals ] if ;

\ load-locals [
    pop-literal nip
    [ dup reverse <effect> infer-shuffle ]
    [ infer->r ]
    bi
] "infer" set-word-prop

\ get-local [
    pop-literal nip
    [ infer-r> ]
    [ dup 0 prefix <effect> infer-shuffle ]
    [ infer->r ]
    tri
] "infer" set-word-prop

\ drop-locals [
    pop-literal nip
    [ infer-r> ]
    [ { } <effect> infer-shuffle ] bi
] "infer" set-word-prop
