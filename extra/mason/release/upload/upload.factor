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

: upload ( -- )
    upload-to-factorcode? get [
        archive-name
        upload-username get
        upload-host get
        remote-archive-name
        upload-safely
    ] when ;
