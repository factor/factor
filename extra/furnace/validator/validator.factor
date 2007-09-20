! Copyright (C) 2006 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: kernel continuations sequences math namespaces math.parser ;
IN: furnace.validator

TUPLE: validation-error reason ;

: apply-validators ( string quot -- obj error/f )
    [
        call f
    ] [
        dup validation-error? [ >r 2drop f r> ] [ rethrow ] if
    ] recover ;

: validation-error ( msg -- * )
    \ validation-error construct-boa throw ;

: v-default ( obj value -- obj )
    over empty? [ nip ] [ drop ] if ;

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
    string>number [
        "must be a number" validation-error
    ] unless* ;
