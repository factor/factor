! Copyright (C) 2003, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: logging.server sequences namespaces concurrency.messaging
words kernel arrays shuffle tools.annotations
prettyprint.config prettyprint debugger io.streams.string
splitting continuations effects arrays.lib parser strings
combinators.lib quotations ;
IN: logging

SYMBOL: DEBUG
SYMBOL: NOTICE
SYMBOL: WARNING
SYMBOL: ERROR
SYMBOL: CRITICAL

: log-levels
    { DEBUG NOTICE NOTICE WARNING ERROR CRITICAL } ;

: send-to-log-server ( array string -- )
    prefix "log-server" get send ;

SYMBOL: log-service

: check-log-message
    pick string?
    pick word?
    pick word? and and
    [ "Bad parameters to log-message" throw ] unless ;

: log-message ( msg word level -- )
    check-log-message
    log-service get dup [
        >r >r >r string-lines r> word-name r> word-name r>
        4array "log-message" send-to-log-server
    ] [
        4drop
    ] if ;

: rotate-logs ( -- )
    { } "rotate-logs" send-to-log-server ;

: close-logs ( -- )
    { } "close-logs" send-to-log-server ;

: with-logging ( service quot -- )
    log-service swap with-variable ; inline

! Aspect-oriented programming idioms

<PRIVATE

: one-string?
    {
        [ dup array? ]
        [ dup length 1 = ]
        [ dup first string? ]
    } && nip ;

: stack>message ( obj -- inputs>message )
    dup one-string? [ first ] [
        H{
            { string-limit f }
            { line-limit 1 }
            { nesting-limit 3 }
            { margin 0 }
        } clone [ unparse ] bind
    ] if ;

PRIVATE>

: (define-logging) ( word level quot -- )
    >r >r dup r> r> 2curry annotate ;

: call-logging-quot ( quot word level -- quot' )
    "called" -rot [ log-message ] 3curry swap compose ;

: add-logging ( word level -- )
    [ call-logging-quot ] (define-logging) ;

: log-stack ( n word level -- )
    log-service get [
        >r >r [ ndup ] keep narray stack>message
        r> r> log-message
    ] [
        3drop
    ] if ; inline

: input# stack-effect effect-in length ;

: input-logging-quot ( quot word level -- quot' )
    over input# -rot [ log-stack ] 3curry swap compose ;

: add-input-logging ( word level -- )
    [ input-logging-quot ] (define-logging) ;

: output# stack-effect effect-out length ;

: output-logging-quot ( quot word level -- quot' )
    over output# -rot [ log-stack ] 3curry compose ;

: add-output-logging ( word level -- )
    [ output-logging-quot ] (define-logging) ;

: (log-error) ( object word level -- )
    log-service get [
        >r >r [ print-error ] with-string-writer r> r> log-message
    ] [
        2drop rethrow
    ] if ;

: log-error ( error word -- ) ERROR (log-error) ;

: log-critical ( error word -- ) CRITICAL (log-error) ;

: stack-balancer ( effect word -- quot )
    >r dup effect-in length r> [ over >r ERROR log-stack r> ndrop ] 2curry
    swap effect-out length f <repetition> append >quotation ;

: error-logging-quot ( quot word -- quot' )
    [ [ log-error ] curry ] keep
    [ stack-effect ] keep stack-balancer compose
    [ recover ] 2curry ;

: add-error-logging ( word level -- )
    [ over >r input-logging-quot r> error-logging-quot ]
    (define-logging) ;

: LOG:
    #! Syntax: name level
    CREATE-WORD
    dup scan-word
    [ >r >r 1array stack>message r> r> log-message ] 2curry
    define ; parsing
