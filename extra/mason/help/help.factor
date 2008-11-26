! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: help.html sequences io.files io.launcher make namespaces
kernel arrays mason.common mason.config ;
IN: mason.help

: make-help-archive ( -- )
    "factor/temp" [
        { "tar" "cfz" "docs.tar.gz" "docs" } try-process
    ] with-directory ;

: upload-help-archive ( -- )
    "factor/temp/docs.tar.gz"
    help-username get
    help-host get
    help-directory get "/docs.tar.gz" append
    upload-safely ;

: (upload-help) ( -- )
    upload-help? get [
        make-help-archive
        upload-help-archive
    ] when ;

: upload-help ( -- )
    status get status-clean eq? [ (upload-help) ] when ;
