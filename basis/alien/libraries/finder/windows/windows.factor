! Copyright (C) 2013 Björn Lindqvist, John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: alien.c-types alien.data alien.libraries.finder
alien.strings arrays combinators.short-circuit environment
io.backend io.files io.files.info io.pathnames kernel sequences
specialized-arrays splitting system system-info.windows
windows.kernel32 ;
SPECIALIZED-ARRAY: ushort
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

: find-library-paths ( name -- path/f )
    candidate-paths [
        { [ file-exists? ] [ file-info regular-file? ] } 1&&
    ] find nip ;

: find-library-file ( name -- path/f )
    f DONT_RESOLVE_DLL_REFERENCES LoadLibraryEx [
        [
            32768 ushort (c-array) [ 32768 GetModuleFileName drop ] keep
            alien>native-string
        ] [ FreeLibrary drop ] bi
    ] [ f ] if* ;

PRIVATE>

M: windows find-library*
    { [ find-library-paths ] [ find-library-file ] } 1|| ;
