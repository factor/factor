! Copyright (C) 2008, 2010 Eduardo Cavazos, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: bootstrap.image.download init io.directories io.launcher
kernel namespaces mason.common mason.platform ;
IN: mason.updates

SYMBOLS: latest-git-id latest-boot-image ;
SYMBOLS: last-git-id last-boot-image ;

[
    f latest-git-id set-global
    f latest-boot-image set-global
    f last-git-id set-global
    f last-boot-image set-global
] "mason.updates" add-startup-hook

: git-pull-cmd ( -- cmd )
    {
        "git"
        "pull"
        "--no-summary"
        "git://factorcode.org/git/factor.git"
        "master"
    } ;

: update-source ( -- )
    git-pull-cmd short-running-process
    git-id latest-git-id set-global ;

: update-boot-image ( -- )
    boot-image-name
    [ maybe-download-image drop ]
    [ file-checksum latest-boot-image set-global ] bi ;

: update-code ( -- )
    update-source
    update-boot-image ;

: new-source-available? ( -- ? )
    last-git-id get-global latest-git-id get-global = not ;

: new-image-available? ( -- ? )
    last-boot-image get-global latest-boot-image get-global = not ;

: build? ( -- ? )
    new-source-available? new-image-available? or ;

: finish-build ( -- )
    #! If the build completed (successfully or not) without
    #! mason crashing or being killed, don't build this git ID
    #! and boot image hash again.
    latest-git-id get-global last-git-id set-global
    latest-boot-image get-global last-boot-image set-global ;
