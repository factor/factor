! Copyright (C) 2009 Sam Anklesaria.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs concurrency.distributed
concurrency.messaging continuations effects init kernel
namespaces sequences sets threads vocabs vocabs.parser ;
IN: modules.rpc-server
<PRIVATE
TUPLE: rpc-request args vocabspec wordname ;
SYMBOL: serving-vocabs serving-vocabs [ V{ } clone ] initialize

: register-gets-thread ( -- )
    [ receive [ data>> dup serving-vocabs get-global index
        [ vocab-words [ stack-effect ] { } assoc-map-as ]
        [ \ no-vocab boa ] if
    ] keep reply-synchronous 
    t ] "get-words" spawn-server "gets-thread" swap register-process ;

: register-does-thread ( -- )
    [ receive [ data>> dup vocabspec>> serving-vocabs get-global index
        [ [ args>> ] [ wordname>> ] [ vocabspec>> vocab-words ] tri at [ execute ] curry with-datastack ]
        [ vocabspec>> \ no-vocab boa ] if
    ] keep reply-synchronous
    t ] "do-word" spawn-server "does-thread" swap register-process ;

: register-loads-thread ( -- )
    [ [ receive vocab ] keep reply-synchronous t ] "load-words" spawn-server "loads-thread" swap register-process ;

: add-vocabs-hook ( -- )
    [ 9012 start-node
        register-gets-thread
        register-does-thread
        register-loads-thread
    ] "start-serving-vocabs" add-init-hook ;
PRIVATE>
SYNTAX: service add-vocabs-hook
    current-vocab name>> serving-vocabs get-global adjoin ;
