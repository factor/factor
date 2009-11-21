! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.strings assocs io.backend
kernel namespaces destructors ;
IN: alien.libraries

: dlopen ( path -- dll ) native-string>alien (dlopen) ;

: dlsym ( name dll -- alien ) [ string>symbol ] dip (dlsym) ;

SYMBOL: libraries

libraries [ H{ } clone ] initialize

TUPLE: library path abi dll ;

: library ( name -- library ) libraries get at ;

: <library> ( path abi -- library )
    over dup [ dlopen ] when \ library boa ;

: load-library ( name -- dll )
    library dup [ dll>> ] when ;

M: dll dispose dlclose ;

M: library dispose dll>> [ dispose ] when* ;

: remove-library ( name -- )
    libraries get delete-at* [ dispose ] [ drop ] if ;

: add-library ( name path abi -- )
    [ 2drop remove-library ]
    [ <library> swap libraries get set-at ] 3bi ;