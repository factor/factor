! Copyright (C) 2013 Björn Lindqvist
! See http://factorcode.org/license.txt for BSD license

USING: alien.libraries alien.libraries.finder arrays combinators
kernel sequences system ;

IN: alien.libraries.finder.windows

<PRIVATE

: candidate-paths ( name -- paths )
    {
        [ ".dll" append ]
        [ "lib" ".dll" surround ]
        [ "dlls/" ".dll" surround ]
        [ "dlls/lib" ".dll" surround ]
    } cleave 4array ;

PRIVATE>

M: windows find-library
    candidate-paths [ dlopen dll-valid? ] map-find nip ;
