! Copyright (C) 2008, 2010 Eduardo Cavazos, Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: bootstrap.image.download http.client init kernel
mason.config mason.git mason.platform math.parser namespaces ;
IN: mason.updates

TUPLE: sources git-id boot-image counter ;

C: <sources> sources

SYMBOLS: latest-sources last-built-sources ;

STARTUP-HOOK: [
    f latest-sources set-global
    f last-built-sources set-global
]

: latest-boot-image ( -- boot-image )
    target-boot-image-name
    [ maybe-download-image drop ] [ file-checksum ] bi ;

: latest-counter ( -- counter )
    counter-url get-global http-get nip string>number ;

: update-sources ( -- )
    ! Must be run from builds-dir
    git-clone-or-pull latest-boot-image latest-counter <sources>
    latest-sources set-global ;

: should-build? ( -- ? )
    latest-sources get-global last-built-sources get-global = not ;

: finish-build ( -- )
    ! If the build completed (successfully or not) without
    ! mason crashing or being killed, don't build this git ID
    ! and boot image hash again.
    latest-sources get-global last-built-sources set-global ;
