! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: checksums checksums.openssl splitting assocs
kernel io.files bootstrap.image sequences io namespaces make
io.launcher math io.encodings.ascii io.files.temp io.pathnames
io.directories ;
IN: bootstrap.image.upload

SYMBOL: upload-images-destination

: destination ( -- dest )
  upload-images-destination get
  "slava@factorcode.org:/var/www/factorcode.org/newsite/images/latest/"
  or ;

: checksums ( -- temp ) "checksums.txt" temp-file ;

: boot-image-names ( -- seq ) images [ boot-image-name ] map ;

: compute-checksums ( -- )
    checksums ascii [
        boot-image-names [
            [ write bl ]
            [ openssl-md5 checksum-file hex-string print ]
            bi
        ] each
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
