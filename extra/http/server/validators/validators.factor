! Copyright (C) 2006, 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: kernel continuations sequences math namespaces
math.parser assocs new-slots ;
IN: http.server.validators

TUPLE: validation-error value reason ;

: validation-error ( value reason -- * )
    \ validation-error construct-boa throw ;

: with-validator ( string quot -- result error? )
    [ f ] compose curry
    [ dup validation-error? [ t ] [ rethrow ] if ] recover ; inline

: validate-param ( name validator assoc -- error? )
    swap pick
    >r >r at r> with-validator swap r> set ;

: validate-params ( validators assoc -- error? )
    [ validate-param ] curry { } assoc>map [ ] contains? ;

: v-default ( str def -- str )
    over empty? spin ? ;

: v-required ( str -- str )
    dup empty? [ "required" validation-error ] when ;

: v-min-length ( str n -- str )
    over length over < [
        [ "must be at least " % # " characters" % ] "" make
        validation-error
    ] [
        drop
    ] if ;

: v-max-length ( str n -- str )
    over length over > [
        [ "must be no more than " % # " characters" % ] "" make
        validation-error
    ] [
        drop
    ] if ;

: v-number ( str -- n )
    dup string>number [ ] [
        "must be a number" validation-error
    ] ?if ;

: v-min-value ( str n -- str )
    2dup < [
        [ "must be at least " % # ] "" make
        validation-error
    ] [
        drop
    ] if ;

: v-max-value ( str n -- str )
    2dup > [
        [ "must be no more than " % # ] "" make
        validation-error
    ] [
        drop
    ] if ;
