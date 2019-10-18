! Copyright (C) 2008, 2010 Eduardo Cavazos, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: bootstrap.image.download http.client init kernel
math.parser namespaces mason.config mason.common mason.git
mason.platform ;
IN: mason.updates

TUPLE: sources git-id boot-image counter ;

C: <sources> sources

SYMBOLS: latest-sources last-built-sources ;

[
    f latest-sources set-global
    f last-built-sources set-global
] "mason.updates" add-startup-hook

: latest-boot-image ( -- boot-image )
    boot-image-name
    [ maybe-download-image drop ] [ file-checksum ] bi ;

: latest-counter ( -- counter )
    counter-url get-global http-get nip string>number ;

: update-sources ( -- )
    #! Must be run from builds-dir
    git-pull latest-boot-image latest-counter <sources>
    latest-sources set-global ;

: build? ( -- ? )
    latest-sources get-global last-built-sources get-global = not ;

: finish-build ( -- )
    #! If the build completed (successfully or not) without
    #! mason crashing or being killed, don't build this git ID
    #! and boot image hash again.
    latest-sources get-global last-built-sources set-global ;
