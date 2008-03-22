! Copyright (C) 2006, 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: kernel continuations sequences math namespaces
math.parser assocs regexp fry unicode.categories
combinators.cleave sequences ;
IN: http.server.validators

SYMBOL: validation-failed?

TUPLE: validation-error value reason ;

C: <validation-error> validation-error

: with-validator ( value quot -- result )
    [ validation-failed? on <validation-error> ] recover ;
    inline

: v-default ( str def -- str )
    over empty? spin ? ;

: v-required ( str -- str )
    dup empty? [ "required" throw ] when ;

: v-min-length ( str n -- str )
    over length over < [
        [ "must be at least " % # " characters" % ] "" make
        throw
    ] [
        drop
    ] if ;

: v-max-length ( str n -- str )
    over length over > [
        [ "must be no more than " % # " characters" % ] "" make
        throw
    ] [
        drop
    ] if ;

: v-number ( str -- n )
    dup string>number [ ] [ "must be a number" throw ] ?if ;

: v-integer ( n -- n )
    dup integer? [ "must be an integer" throw ] unless ;

: v-min-value ( x n -- x )
    2dup < [
        [ "must be at least " % # ] "" make throw
    ] [
        drop
    ] if ;

: v-max-value ( x n -- x )
    2dup > [
        [ "must be no more than " % # ] "" make throw
    ] [
        drop
    ] if ;

: v-regexp ( str what regexp -- str )
    >r over r> matches?
    [ drop ] [ "invalid " prepend throw ] if ;

: v-email ( str -- str )
    #! From http://www.regular-expressions.info/email.html
    "e-mail"
    R/ [A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}/i
    v-regexp ;

: v-captcha ( str -- str )
    dup empty? [ "must remain blank" throw ] unless ;

: v-one-line ( str -- str )
    dup "\r\n" seq-intersect empty?
    [ "must be a single line" throw ] unless ;

: v-one-word ( str -- str )
    dup [ alpha? ] all?
    [ "must be a single word" throw ] unless ;
