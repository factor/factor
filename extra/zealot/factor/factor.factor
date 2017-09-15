! Copyright (C) 2017 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays bootstrap.image cli.git combinators formatting fry
http.client io.directories io.launcher kernel math.parser
sequences system system-info zealot ;
IN: zealot.factor

: download-boot-checksums ( path branch -- )
    '[ _ "http://downloads.factorcode.org/images/%s/checksums.txt" sprintf download ] with-directory ;

: download-boot-image ( path branch image-name -- )
    '[ _ _ "http://downloads.factorcode.org/images/%s/%s" sprintf download ] with-directory ;

: download-my-boot-image ( path branch -- )
    my-boot-image-name download-boot-image ;

HOOK: compile-factor os ( path -- process )
M: unix compile-factor ( path -- process )
    [ { "make" "-j" } cpus number>string suffix run-process ] with-directory ;

M: windows compile-factor ( path -- process )
    [ { "nmake" "/f" "NMakefile" "x86-64" } run-process ] with-directory ;

: bootstrap-factor ( path -- )
    [ "./factor" "-i=" my-boot-image-name append 2array try-output-process ] with-directory ;

: build-sh-update-factor ( path -- process )
    [ { "build.sh" "update" } run-process ] with-directory ;

: factor-load-all ( path -- )
    [
        "./factor" "-e=\"USE: vocabs.hierarchy load-all USE: memory \"factor.image.load-all\" save-image\"" 2array
        run-process drop
    ] with-directory ;

: build-new-factor ( branch -- )
    [ "factor" "factor" zealot-github-clone-paths nip ] dip
    {
        [ drop "factor" "factor" zealot-github-add-build-remote drop ]
        [ drop [ git-fetch-all* ] with-directory drop ]
        [ zealot-build-checkout-branch drop ]
        [ download-my-boot-image ]
        [ download-boot-checksums ]
        [ drop compile-factor drop ]
        [ drop bootstrap-factor ]
        [ drop factor-load-all ]
    } 2cleave ;