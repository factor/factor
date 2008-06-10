! Copyright (C) 2003, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: logging.server sequences namespaces concurrency.messaging
words kernel arrays shuffle tools.annotations
prettyprint.config prettyprint debugger io.streams.string
splitting continuations effects arrays.lib parser strings
combinators.lib quotations fry symbols accessors ;
IN: logging

SYMBOLS: DEBUG NOTICE WARNING ERROR CRITICAL ;

: log-levels { DEBUG NOTICE NOTICE WARNING ERROR CRITICAL } ;

: send-to-log-server ( array string -- )
    prefix "log-server" get send ;

SYMBOL: log-service

: check-log-message ( msg word level -- msg word level )
    3dup [ string? ] [ word? ] [ word? ] tri* and and
    [ "Bad parameters to log-message" throw ] unless ; inline

: log-message ( msg word level -- )
    check-log-message
    log-service get dup [
        [ [ string-lines ] [ word-name ] [ word-name ] tri* ] dip
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

: one-string? ( obj -- ? )
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
    [ dup ] 2dip 2curry annotate ;

: call-logging-quot ( quot word level -- quot' )
    "called" -rot [ log-message ] 3curry prepose ;

: add-logging ( word level -- )
    [ call-logging-quot ] (define-logging) ;

: log-stack ( n word level -- )
    log-service get [
        [ [ ndup ] keep narray stack>message ] 2dip log-message
    ] [
        3drop
    ] if ; inline

: input# ( word -- n ) stack-effect in>> length ;

: input-logging-quot ( quot word level -- quot' )
    rot [ [ input# ] keep ] 2dip '[ , , , log-stack @ ] ;

: add-input-logging ( word level -- )
    [ input-logging-quot ] (define-logging) ;

: output# ( word -- n ) stack-effect out>> length ;

: output-logging-quot ( quot word level -- quot' )
    [ [ output# ] keep ] dip '[ @ , , , log-stack ] ;

: add-output-logging ( word level -- )
    [ output-logging-quot ] (define-logging) ;

: (log-error) ( object word level -- )
    log-service get [
        [ [ print-error ] with-string-writer ] 2dip log-message
    ] [
        2drop rethrow
    ] if ;

: log-error ( error word -- ) ERROR (log-error) ;

: log-critical ( error word -- ) CRITICAL (log-error) ;

: stack-balancer ( effect -- quot )
    [ in>> length [ ndrop ] curry ]
    [ out>> length f <repetition> >quotation ]
    bi append ;

: error-logging-quot ( quot word -- quot' )
    dup stack-effect stack-balancer
    '[ , [ , log-error @ ] recover ] ;

: add-error-logging ( word level -- )
    [ [ input-logging-quot ] 2keep drop error-logging-quot ]
    (define-logging) ;

: LOG:
    #! Syntax: name level
    CREATE-WORD dup scan-word
    '[ 1array stack>message , , log-message ]
    (( message -- )) define-declared ; parsing
