! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: bootstrap.image.upload
USING: http.client crypto.md5 splitting assocs kernel io.files
bootstrap.image sequences io namespaces io.launcher math ;

SYMBOL: upload-images-destination

: destination ( -- dest )
  upload-images-destination get
  "slava@/var/www/factorcode.org/newsite/images/latest/"
  or ;

: checksums "checksums.txt" temp-file ;

: boot-image-names images [ boot-image-name ] map ;

: compute-checksums ( -- )
    checksums [
        boot-image-names [ dup write bl file>md5str print ] each
    ] with-file-writer ;

: upload-images ( -- )
    [
        "scp" ,
        boot-image-names %
        "temp/checksums.txt" , destination ,
    ] { } make try-process ;

: new-images ( -- )
    "" resource-path
      [ make-images compute-checksums upload-images ]
    with-directory ;

MAIN: new-images
