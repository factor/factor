! Copyright (C) 2006, 2010 Slava Pestov
! See https://factorcode.org/license.txt for BSD license.
USING: kernel make math math.functions math.parser ranges regexp
sequences sets unicode xmode.catalog ;
IN: validators

: v-checkbox ( str -- ? )
    >lower "on" = ;

: v-default ( str def -- str/def )
    [ drop empty? not ] most ;

: v-required ( str -- str )
    dup empty? [ "required" throw ] when ;

: v-optional ( str quot -- result )
    over empty? [ 2drop f ] [ call ] if ; inline

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
    [ string>number ] [ "must be a number" throw ] ?unless ;

: v-integer ( str -- n )
    v-number dup integer? [ "must be an integer" throw ] unless ;

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
    3dup nip matches?
    [ 2drop ] [ drop "invalid " prepend throw ] if ;

: v-email ( str -- str )
    ! From https://www.regular-expressions.info/email.html
    320 v-max-length
    "e-mail"
    R/ [A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}/i
    v-regexp ;

: v-url ( str -- str )
    "URL" R/ (?:ftp|http|https):\/\/\S+/ v-regexp ;

: v-captcha ( str -- str )
    dup empty? [ "must remain blank" throw ] unless ;

: v-one-line ( str -- str )
    v-required
    dup "\r\n" intersects?
    [ "must be a single line" throw ] when ;

: v-one-word ( str -- str )
    v-required
    dup [ alpha? ] all?
    [ "must be a single word" throw ] unless ;

: v-username ( str -- str )
    2 v-min-length 16 v-max-length v-one-word ;

: v-password ( str -- str )
    6 v-min-length 40 v-max-length v-one-line ;

: v-mode ( str -- str )
    dup mode-names member? [
        "not a valid syntax mode" throw
    ] unless ;

: luhn? ( str -- ? )
    string>digits <reversed>
    [ odd? [ 2 * 10 /mod + ] when ] map-index
    sum 10 divisor? ;

: v-credit-card ( str -- n )
    "- " without
    dup CHAR: 0 CHAR: 9 [a..b] diff empty? [
        13 v-min-length
        16 v-max-length
        dup luhn? [ string>number ] [
            "card number check failed" throw
        ] if
    ] [
        "invalid credit card number format" throw
    ] if ;
