! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays hashtables help.html http.client io.directories
io.files io.launcher kernel make mason.common mason.config
namespaces sequences ;
IN: mason.docs

: make-docs-archive ( -- )
    "factor/temp" [
        { "tar" "cfz" "docs.tar.gz" "docs" } short-running-process
    ] with-directory ;

: upload-docs-archive ( -- )
    "factor/temp/docs.tar.gz"
    docs-username get
    docs-host get
    docs-directory get "/docs.tar.gz" append
    upload-safely ;

: notify-docs ( -- )
    status-secret get "secret" associate
    docs-update-url get
    http-post
    2drop ;

: upload-docs ( -- )
    upload-docs? get [
        make-docs-archive
        upload-docs-archive
        notify-docs
    ] when ;