! Copyright (C) 2006, 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: kernel continuations sequences math namespaces sets
math.parser assocs regexp fry unicode.categories sequences
arrays hashtables words combinators mirrors classes quotations ;
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
    dup "\r\n" intersect empty?
    [ "must be a single line" throw ] unless ;

: v-one-word ( str -- str )
    dup [ alpha? ] all?
    [ "must be a single word" throw ] unless ;

SYMBOL: validation-messages

: with-validation ( quot -- messages )
    V{ } clone [
        validation-messages rot with-variable
    ] keep ; inline

: (validation-message) ( obj -- )
    validation-messages get push ;

: (validation-message-for) ( obj name -- )
    swap 2array (validation-message) ;

TUPLE: validation-message message ;

C: <validation-message> validation-message

: validation-message ( string -- )
    <validation-message> (validation-message) ;

: validation-message-for ( string name -- )
    [ <validation-message> ] dip (validation-message-for) ;

TUPLE: validation-error value message ;

C: <validation-error> validation-error

: validation-error ( reason -- )
    f <validation-error> (validation-message) ;

: validation-error-for ( reason value name -- )
    [ <validation-error> ] dip (validation-message-for) ;

: validation-failed? ( -- ? )
    validation-messages get [
        dup pair? [ second ] when validation-error?
    ] contains? ;

: define-validators ( class validators -- )
    >hashtable "validators" set-word-prop ;

: validate ( value name quot -- result )
    [ swap validation-error-for f ] recover ; inline

: validate-value ( value name validators -- result )
    '[
        , at {
            { [ dup pair? ] [ first ] }
            { [ dup quotation? ] [ ] }
        } cond call
    ] validate ;

: required-values ( assoc -- )
    [ swap [ drop v-required ] validate drop ] assoc-each ;

: validate-values ( assoc validators -- assoc' )
    '[ over , validate-value ] assoc-map ;

: deposit-values ( destination assoc validators -- )
    validate-values update ;

: deposit-slots ( tuple assoc -- )
    [ [ <mirror> ] [ class "validators" word-prop ] bi ] dip
    swap deposit-values ;
