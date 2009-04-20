! Copyright (C) 2008 Eduardo Cavazos, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel namespaces make sequences arrays io io.files
io.launcher mason.common mason.platform
mason.release.archive mason.config ;
IN: mason.release.upload

: remote-location ( -- dest )
    upload-directory get "/" platform 3append ;

: remote-archive-name ( archive-name -- dest )
    [ remote-location "/" ] dip 3append ;

: upload ( archive-name -- )
    upload-to-factorcode? get [
        upload-username get
        upload-host get
        pick remote-archive-name
        upload-safely
    ] [ drop ] if ;
