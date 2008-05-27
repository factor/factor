! Copyright (C) 2006, 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: kernel continuations sequences sequences.lib math
namespaces sets math.parser math.ranges assocs regexp fry
unicode.categories arrays hashtables words combinators mirrors
classes quotations xmode.catalog ;
IN: validators

: v-default ( str def -- str )
    over empty? spin ? ;

: v-required ( str -- str )
    dup empty? [ "required" throw ] when ;

: v-optional ( str quot -- str )
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
    dup string>number [ ] [ "must be a number" throw ] ?if ;

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
    >r over r> matches?
    [ drop ] [ "invalid " prepend throw ] if ;

: v-email ( str -- str )
    #! From http://www.regular-expressions.info/email.html
    60 v-max-length
    "e-mail"
    R' [A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}'i
    v-regexp ;

: v-url ( str -- str )
    "URL"
    R' (ftp|http|https)://(\w+:?\w*@)?(\S+)(:[0-9]+)?(/|/([\w#!:.?+=&%@!\-/]))?'
    v-regexp ;

: v-captcha ( str -- str )
    dup empty? [ "must remain blank" throw ] unless ;

: v-one-line ( str -- str )
    v-required
    dup "\r\n" intersect empty?
    [ "must be a single line" throw ] unless ;

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

: luhn? ( n -- ? )
    string>digits <reversed>
    [ odd? [ 2 * 10 /mod + ] when ] map-index
    sum 10 mod 0 = ;

: v-credit-card ( str -- n )
    "- " diff
    dup CHAR: 0 CHAR: 9 [a,b] diff empty? [
        13 v-min-length
        16 v-max-length
        dup luhn? [ string>number ] [
            "card number check failed" throw
        ] if
    ] [
        "invalid credit card number format" throw
    ] if ;

SYMBOL: validation-messages
SYMBOL: named-validation-messages

: init-validation ( -- )
    V{ } clone validation-messages set
    H{ } clone named-validation-messages set ;

: (validation-message) ( obj -- )
    validation-messages get push ;

: (validation-message-for) ( obj name -- )
    named-validation-messages get set-at ;

TUPLE: validation-message message ;

C: <validation-message> validation-message

: validation-message ( string -- )
    <validation-message> (validation-message) ;

: validation-message-for ( string name -- )
    [ <validation-message> ] dip (validation-message-for) ;

TUPLE: validation-error message value ;

C: <validation-error> validation-error

: validation-error ( message -- )
    f <validation-error> (validation-message) ;

: validation-error-for ( message value name -- )
    [ <validation-error> ] dip (validation-message-for) ;

: validation-failed? ( -- ? )
    validation-messages get [ validation-error? ] contains?
    named-validation-messages get [ nip validation-error? ] assoc-contains?
    or ;

: define-validators ( class validators -- )
    >hashtable "validators" set-word-prop ;

: validate ( value name quot -- result )
    '[ drop @ ] [ -rot validation-error-for f ] recover ; inline

: required-values ( assoc -- )
    [ swap [ v-required ] validate drop ] assoc-each ;

: validate-values ( assoc validators -- assoc' )
    swap '[ [ [ dup , at ] keep ] dip validate ] assoc-map ;
