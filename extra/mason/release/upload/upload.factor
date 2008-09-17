! Copyright (C) 2008 Eduardo Cavazos, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel namespaces make sequences arrays io io.files
io.launcher mason.common mason.platform
mason.release.archive mason.config ;
IN: mason.release.upload

: remote-location ( -- dest )
    upload-directory get "/" platform 3append ;

: remote-archive-name ( -- dest )
    remote-location "/" archive-name 3append ;

: temp-archive-name ( -- dest )
    remote-archive-name ".incomplete" append ;

: upload-command ( -- args )
    "scp"
    archive-name
    [
        upload-username get % "@" %
        upload-host get % ":" %
        temp-archive-name %
    ] "" make
    3array ;

: rename-command ( -- args )
    [
        "ssh" ,
        upload-host get ,
        "-l" ,
        upload-username get ,
        "mv" ,
        temp-archive-name ,
        remote-archive-name ,
    ] { } make ;

: upload-temp-file ( -- )
    upload-command short-running-process ;

: rename-temp-file ( -- )
    rename-command short-running-process ;

: upload ( -- )
    upload-to-factorcode get
    [ upload-temp-file rename-temp-file ]
    when ;
