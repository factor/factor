! Copyright (C) 2008 Eduardo Cavazos, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel namespaces sequences prettyprint io.files
io.launcher make
mason.common mason.platform mason.config ;
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
        "scp" ,
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
