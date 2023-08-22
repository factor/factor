! Copyright (C) 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: hashtables kernel assocs accessors math arrays sequences ;
IN: pairs

TUPLE: pair value key hash ;

: <pair> ( value key -- assoc )
    f pair boa ; inline

: if-hash ( pair true-quot false-quot -- )
    [ hash>> ] -rot ?if ; inline

M: pair assoc-size
    [ assoc-size 1 + ] [ drop 1 ] if-hash ; inline

: if-key ( key pair true-quot false-quot -- )
    [ [ 2dup key>> eq? ] dip [ nip ] prepose ] dip if ; inline

M: pair at*
    [ value>> t ] [
        [ at* ] [ 2drop f f ] if-hash
    ] if-key ; inline

M: pair set-at
    [ value<< ] [
        [ set-at ]
        [ [ associate ] dip swap >>hash drop ] if-hash
    ] if-key ; inline

ERROR: cannot-delete-key pair ;

M: pair delete-at
    [ cannot-delete-key ] [
        [ delete-at ] [ 2drop ] if-hash
    ] if-key ; inline

M: pair >alist
    [ hash>> >alist ] [ [ key>> ] [ value>> ] bi 2array ] bi suffix ; inline

INSTANCE: pair assoc
