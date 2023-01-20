! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: hashtables http.client io.files.temp io.pathnames kernel
mason.common mason.config namespaces sequences ;
IN: mason.docs

: make-docs-archive ( -- )
    [
        { "tar" "cfz" }
        "docs.tar.gz" temp-file suffix
        "docs" suffix
        short-running-process
    ] with-cache-directory ;

: upload-docs-archive ( -- )
    "docs.tar.gz" temp-file
    docs-username get
    docs-host get
    docs-directory get "docs.tar.gz" append-path
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
