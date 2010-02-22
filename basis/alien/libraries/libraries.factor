! Copyright (C) 2009, 2010 Slava Pestov, Joe Groff.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.strings assocs io.backend
kernel namespaces destructors sequences system io.pathnames ;
IN: alien.libraries

: dlopen ( path -- dll ) native-string>alien (dlopen) ;

: dlsym ( name dll -- alien ) [ string>symbol ] dip (dlsym) ;

SYMBOL: libraries

libraries [ H{ } clone ] initialize

TUPLE: library path abi dll ;

ERROR: no-library name ;

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

: library-abi ( library -- abi )
    library [ abi>> ] [ "cdecl" ] if* ;

SYMBOL: deploy-libraries

deploy-libraries [ V{ } clone ] initialize

: deploy-library ( name -- )
    dup libraries get key?
    [ deploy-libraries get 2dup member? [ 2drop ] [ push ] if ]
    [ no-library ] if ;

<PRIVATE

HOOK: >deployed-library-path os ( path -- path' )

M: windows >deployed-library-path
    file-name ;

M: unix >deployed-library-path
    file-name "$ORIGIN" prepend-path ;

M: macosx >deployed-library-path
    file-name "@executable_path/../Frameworks" prepend-path ;

PRIVATE>
