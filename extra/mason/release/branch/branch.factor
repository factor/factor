! Copyright (C) 2008 Eduardo Cavazos, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io.directories io.files io.launcher kernel make
mason.common mason.config mason.platform namespaces prettyprint
sequences ;
IN: mason.release.branch

: branch-name ( -- string ) "clean-" platform append ;

: refspec ( -- string ) "master:" branch-name append ;

: push-to-clean-branch-cmd ( -- args )
    [
        "git" , "push" ,
        [
            branch-username get % "@" %
            branch-host get % ":" %
            branch-directory get %
        ] "" make ,
        refspec ,
    ] { } make ;

: push-to-clean-branch ( -- )
    push-to-clean-branch-cmd short-running-process ;

: upload-clean-image-cmd ( -- args )
    [
        scp-command get ,
        boot-image-name ,
        [
            image-username get % "@" %
            image-host get % ":" %
            image-directory get % "/" %
            platform %
        ] "" make ,
    ] { } make ;

: upload-clean-image ( -- )
    upload-clean-image-cmd short-running-process ;

: (update-clean-branch) ( -- )
    "factor" [
        push-to-clean-branch
        upload-clean-image
    ] with-directory ;

: update-clean-branch ( -- )
    upload-to-factorcode? get [ (update-clean-branch) ] when ;
