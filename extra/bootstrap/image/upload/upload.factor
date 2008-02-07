! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: bootstrap.image.upload
USING: http.client crypto.md5 splitting assocs kernel io.files
bootstrap.image sequences io namespaces io.launcher math ;

: destination "slava@factorcode.org:www/images/latest/" ;

: boot-image-names images [ boot-image-name ] map ;

: compute-checksums ( -- )
    "checksums.txt" [
        boot-image-names [ dup write bl file>md5str print ] each
    ] with-file-out ;

: upload-images ( -- )
    [
        "scp" , boot-image-names % "checksums.txt" , destination ,
    ] { } make run-process
    wait-for-process zero? [ "Upload failed" throw ] unless ;

: new-images ( -- )
    make-images compute-checksums upload-images ;

MAIN: new-images
