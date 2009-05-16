! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays help.html io.directories io.files io.launcher
kernel make mason.common mason.config namespaces sequences ;
IN: mason.help

: make-help-archive ( -- )
    "factor/temp" [
        { "tar" "cfz" "docs.tar.gz" "docs" } short-running-process
    ] with-directory ;

: upload-help-archive ( -- )
    "factor/temp/docs.tar.gz"
    help-username get
    help-host get
    help-directory get "/docs.tar.gz" append
    upload-safely ;

: upload-help ( -- )
    upload-help? get [
        make-help-archive
        upload-help-archive
    ] when ;