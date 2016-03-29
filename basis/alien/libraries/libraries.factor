! Copyright (C) 2009, 2010 Slava Pestov, Joe Groff.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.strings assocs compiler.errors
io.backend kernel namespaces destructors sequences strings
system io.pathnames fry combinators vocabs ;
IN: alien.libraries

PRIMITIVE: dll-valid? ( dll -- ? )
PRIMITIVE: (dlopen) ( path -- dll )
PRIMITIVE: (dlsym) ( name dll -- alien )
PRIMITIVE: dlclose ( dll -- )
PRIMITIVE: (dlsym-raw) ( name dll -- alien )

: dlopen ( path -- dll ) native-string>alien (dlopen) ;

: dlsym ( name dll -- alien ) [ string>symbol ] dip (dlsym) ;

: dlsym-raw ( name dll -- alien ) [ string>symbol ] dip (dlsym-raw) ;

HOOK: dlerror os ( -- message/f )

SYMBOL: libraries

libraries [ H{ } clone ] initialize

TUPLE: library { path string } dll dlerror { abi abi initial: cdecl } ;

C: <library> library

: lookup-library ( name -- library ) libraries get at ;

ERROR: no-library-named name ;
GENERIC: dlsym? ( name string/dll -- ? )
M: string dlsym? dup lookup-library [ nip dll>> dlsym? ] [ no-library-named ] if* ;
M: dll dlsym? dlsym >boolean ;

: open-dll ( path -- dll dll-error/f )
    [ dlopen dup dll-valid? [ f ] [ dlerror ] if ]
    [ f f ] if* ;

: make-library ( path abi -- library )
    [ dup open-dll ] dip <library> ;

: library-dll ( library -- dll )
    dup [ dll>> ] when ;

: load-library ( name -- dll )
    lookup-library library-dll ;

M: dll dispose dlclose ;

M: library dispose dll>> [ dispose ] when* ;

: remove-library ( name -- )
    libraries get delete-at* [ dispose ] [ drop ] if ;

: same-library? ( library path abi -- ? )
    [ swap path>> = ] [ swap abi>> = ] bi-curry* bi and ;

: add-library? ( name path abi -- ? )
    [ lookup-library ] 2dip '[ _ _ same-library? not ] [ t ] if* ;

: add-library ( name path abi -- )
    3dup add-library? [
        [ 2drop remove-library ]
        [ [ nip ] dip make-library ]
        [ 2drop libraries get set-at ] 3tri
    ] [ 3drop ] if ;

: change-dll ( library path abi -- )
    swap >>abi
    swap >>path
    [ dispose ]
    [ path>> open-dll ]
    [ swap >>dlerror swap >>dll drop ] tri ;

: update-library ( name path abi -- )
    pick lookup-library [
        [ 2over same-library? not ] keep swap
        [ change-dll drop ] [ 4drop ] if
    ] [
        make-library swap libraries get set-at
    ] if* ;

: library-abi ( library -- abi )
    lookup-library [ abi>> ] [ cdecl ] if* ;

: address-of ( name library -- value )
    2dup load-library dlsym-raw
    [ 2nip ] [ no-such-symbol ] if* ;

SYMBOL: deploy-libraries

deploy-libraries [ V{ } clone ] initialize

: deploy-library ( name -- )
    dup libraries get key?
    [ deploy-libraries get 2dup member? [ 2drop ] [ push ] if ]
    [ "deploy-library failure" no-such-library ] if ;

HOOK: >deployed-library-path os ( path -- path' )

{
    { [ os windows? ] [ "alien.libraries.windows" ] }
    { [ os unix? ] [ "alien.libraries.unix" ] }
} cond require
