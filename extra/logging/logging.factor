! Copyright (C) 2003, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: logging.server sequences namespaces concurrency
words kernel arrays shuffle tools.annotations
prettyprint.config prettyprint debugger io.streams.string
splitting continuations effects arrays.lib parser strings
combinators.lib ;
IN: logging

SYMBOL: DEBUG
SYMBOL: NOTICE
SYMBOL: WARNING
SYMBOL: ERROR
SYMBOL: CRITICAL

: log-levels
    { DEBUG NOTICE NOTICE WARNING ERROR CRITICAL } ;

: send-to-log-server ( array string -- )
    add* "log-server" get send ;

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

: close-log-files ( -- )
    { } "close-log-files" send-to-log-server ;

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

: inputs>message ( obj -- inputs>message )
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

: log-inputs ( n word level -- )
    log-service get [
        >r >r [ ndup ] keep narray inputs>message
        r> r> log-message
    ] [
        3drop
    ] if ; inline

: input# stack-effect effect-in length ;

: input-logging-quot ( quot word level -- quot' )
    over input# -rot [ log-inputs ] 3curry swap compose ;

: add-input-logging ( word level -- )
    [ input-logging-quot ] (define-logging) ;

: (log-error) ( object word level -- )
    log-service get [
        >r >r [ print-error ] string-out r> r> log-message
    ] [
        2drop rethrow
    ] if ;

: log-error ( object word -- ) ERROR (log-error) ;

: log-critical ( object word -- ) CRITICAL (log-error) ;

: error-logging-quot ( quot word -- quot' )
    dup stack-effect effect-in length
    [ >r log-error r> ndrop ] 2curry
    [ recover ] 2curry ;

: add-error-logging ( word level -- )
    [ over >r input-logging-quot r> error-logging-quot ]
    (define-logging) ;

: LOG:
    #! Syntax: name level
    CREATE
    dup reset-generic
    dup scan-word
    [ >r >r 1array inputs>message r> r> log-message ] 2curry
    define ; parsing
