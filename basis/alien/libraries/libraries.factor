! Copyright (C) 2009, 2010 Slava Pestov, Joe Groff.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.strings assocs io.backend
kernel namespaces destructors sequences strings
system io.pathnames fry combinators vocabs ;
IN: alien.libraries

: dlopen ( path -- dll ) native-string>alien (dlopen) ;

: dlsym ( name dll -- alien ) [ string>symbol ] dip (dlsym) ;

: dlsym-raw ( name dll -- alien ) [ string>symbol ] dip (dlsym-raw) ;

HOOK: dlerror os ( -- message/f )

SYMBOL: libraries

libraries [ H{ } clone ] initialize

TUPLE: library { path string } { abi abi initial: cdecl } dll dlerror ;

ERROR: no-library name ;

: lookup-library ( name -- library ) libraries get at ;

: <library> ( path abi -- library )
    over dup
    [ dlopen dup dll-valid? [ f ] [ dlerror ] if ] [ f ] if
    \ library boa ;

: library-dll ( library -- dll )
    dup [ dll>> ] when ;

: load-library ( name -- dll )
    lookup-library library-dll ;

M: dll dispose dlclose ;

M: library dispose dll>> [ dispose ] when* ;

: remove-library ( name -- )
    libraries get delete-at* [ dispose ] [ drop ] if ;

: add-library? ( name path abi -- ? )
    [ lookup-library ] 2dip
    '[ [ path>> _ = ] [ abi>> _ = ] bi and not ] [ t ] if* ;

: add-library ( name path abi -- )
    3dup add-library? [
        [ 2drop remove-library ]
        [ <library> swap libraries get set-at ] 3bi
    ] [ 3drop ] if ;

: library-abi ( library -- abi )
    lookup-library [ abi>> ] [ cdecl ] if* ;

ERROR: no-such-symbol name library ;

: address-of ( name library -- value )
    2dup load-library dlsym-raw [ 2nip ] [ no-such-symbol ] if* ;

SYMBOL: deploy-libraries

deploy-libraries [ V{ } clone ] initialize

: deploy-library ( name -- )
    dup libraries get key?
    [ deploy-libraries get 2dup member? [ 2drop ] [ push ] if ]
    [ no-library ] if ;

HOOK: >deployed-library-path os ( path -- path' )

<< {
    { [ os windows? ] [ "alien.libraries.windows" ] }
    { [ os unix? ] [ "alien.libraries.unix" ] }
} cond require >>
