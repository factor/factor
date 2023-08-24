! Copyright (C) 2008, 2011 Eduardo Cavazos, Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel mason.common mason.config mason.platform
namespaces sequences ;
IN: mason.release.upload

: remote-location ( -- dest )
    package-directory get "/" platform 3append ;

: remote-archive-name ( archive-name -- dest )
    [ remote-location "/" ] dip 3append ;

: upload ( archive-name -- )
    upload-package? get [
        package-username get
        package-host get
        pick remote-archive-name
        upload-safely
    ] [ drop ] if ;
