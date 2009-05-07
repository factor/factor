! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.strings assocs io.backend kernel namespaces ;
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

: add-library ( name path abi -- )
    <library> swap libraries get set-at ;