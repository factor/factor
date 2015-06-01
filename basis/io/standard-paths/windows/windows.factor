! Copyright (C) 2011 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs environment fry
io.directories.search.windows io.files io.pathnames
io.standard-paths kernel sequences splitting system
unicode.case ;
IN: io.standard-paths.windows

M: windows find-in-applications
    '[ [ >lower _ tail? ] find-in-program-files ] map-find drop ;

: path ( -- path )
    "PATH" os-env ";" split "." prefix ;

: path-extensions ( command -- commands )
    "PATHEXT" os-env [
        ";" split 2dup [ [ >lower ] bi@ tail? ] with any?
        [ drop 1array ] [ [ append ] with map ] if
    ] [ 1array ] if* ;

M: windows find-in-path*
    path-extensions path
    cartesian-product flip concat
    [ prepend-path ] { } assoc>map
    [ exists? ] find nip ;
