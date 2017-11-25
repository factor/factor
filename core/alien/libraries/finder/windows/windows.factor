! Copyright (C) 2013 Björn Lindqvist, John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: alien.libraries.finder arrays combinators.short-circuit
environment io.backend io.files io.files.info io.pathnames kernel
sequences splitting system system-info.windows ;

IN: alien.libraries.finder.windows

<PRIVATE

: search-paths ( -- seq )
    "resource:" normalize-path
    system-directory
    windows-directory 3array
    "PATH" os-env [ ";" split ] [ f ] if* append ;

: candidate-paths ( name -- seq )
    search-paths over ".dll" tail? [
        [ prepend-path ] with map
    ] [
        [
            [ prepend-path ]
            [ [ ".dll" append ] [ prepend-path ] bi* ] 2bi
            2array
        ] with map concat
    ] if ;

PRIVATE>

M: windows find-library*
    candidate-paths [
        { [ exists? ] [ file-info regular-file? ] } 1&&
    ] find nip ;
