! Copyright (C) 2012 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: arrays assocs combinators.short-circuit command-line
environment io io.backend io.files io.files.info io.pathnames
kernel namespaces sequences sets splitting system unicode ;

IN: tools.which

<PRIVATE

: executable? ( path -- ? )
    {
        [ file-exists? ]
        [ file-executable? ]
        [ file-info directory? not ]
    } 1&& ;

: split-path ( paths -- seq )
    os windows? ";" ":" ? split harvest ;

: path-extensions ( command -- commands )
    "PATHEXT" os-env [
        split-path 2dup [ [ >lower ] bi@ tail? ] with any?
        [ drop 1array ] [ [ append ] with map ] if
    ] [ 1array ] if* ;

: find-which ( commands paths -- file/f )
    [ normalize-path ] map members
    cartesian-product flip concat
    [ prepend-path ] { } assoc>map
    [ executable? ] find nip ;

: (which) ( command path -- file/f )
    split-path os windows? [
        [ path-extensions ] [ "." prefix ] bi*
    ] [ [ 1array ] dip ] if find-which ;

PRIVATE>

: which ( command -- file/f )
    "PATH" os-env (which) ;

: ?which ( command -- file/command )
    [ which ] [ or ] bi ;

: run-which ( -- )
    command-line get [ which [ print ] when* ] each ;

MAIN: run-which
