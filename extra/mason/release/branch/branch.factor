! Copyright (C) 2008, 2010 Eduardo Cavazos, Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: io.directories kernel make mason.common mason.config
mason.platform namespaces sequences ;
IN: mason.release.branch

: branch-name ( -- string ) "clean-" platform append ;

: refspec ( -- string ) "master:" branch-name append ;

: push-to-clean-branch-cmd ( -- args )
    [
        { "git" "push" "-f" } %
        [
            branch-username get % "@" %
            branch-host get % ":" %
            branch-directory get %
        ] "" make ,
        refspec ,
    ] { } make ;

: push-to-clean-branch ( -- )
    5 [ push-to-clean-branch-cmd short-running-process ] retry ;

: upload-clean-image-cmd ( -- args )
    [
        scp-command get ,
        target-boot-image-name ,
        [
            image-username get % "@" %
            image-host get % ":" %
            image-directory get % "/" %
            platform %
        ] "" make ,
    ] { } make ;

: upload-clean-image ( -- )
    5 [ upload-clean-image-cmd short-running-process ] retry ;

: update-clean-branch ( -- )
    update-clean-branch? get [
        "factor" [
            push-to-clean-branch
            upload-clean-image
        ] with-directory
    ] when ;
