! Copyright (C) 2026 Factor authors.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.libraries kernel namespaces sequences system ;
IN: openssl.libraries

<PRIVATE

SYMBOL: selected-openssl-suffix

: library-available? ( path -- ? )
    dlopen [ dll-valid? ] [ dlclose ] bi ;

: find-openssl-library-suffix ( -- suffix )
    { ".so.3" ".so.1.1" ".so" } [
        { "libssl" "libcrypto" } swap
        '[ _ append library-available? ] all?
    ] find nip ".so.3" or ;

: openssl-library-suffix ( -- suffix )
    selected-openssl-suffix get-global [
        find-openssl-library-suffix
        dup selected-openssl-suffix set-global
    ] unless* ;

STARTUP-HOOK: [ f selected-openssl-suffix set-global ]

PRIVATE>

: linux-openssl-library ( name -- path )
    os linux? [ openssl-library-suffix ] [ ".so.3" ] if append ;
