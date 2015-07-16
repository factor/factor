! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: bootstrap.image checksums checksums.openssl io
io.directories io.encodings.ascii io.files io.files.temp
io.launcher kernel make namespaces sequences system ;
IN: bootstrap.image.upload

SYMBOL: upload-images-destination

: destination ( -- dest )
    upload-images-destination get
    "slava_pestov@downloads.factorcode.org:downloads.factorcode.org/images/latest/"
    or ;

: checksums ( -- temp )
    "checksums.txt" temp-file ;

: boot-image-names ( -- seq )
    images [ boot-image-name ] map ;

: compute-checksums ( -- )
    checksums ascii [
        boot-image-names [
            [ write bl ]
            [ openssl-md5 checksum-file hex-string print ]
            bi
        ] each
    ] with-file-writer ;

! Windows scp doesn't like pathnames with colons, it treats them as hostnames.
! Workaround for uploading checksums.txt created with temp-file.
! e.g. C:\Users\\Doug\\AppData\\Local\\Temp/factorcode.org\\Factor/checksums.txt
! ssh: Could not resolve hostname c: no address associated with name

HOOK: scp-name os ( -- path )
M: object scp-name "scp" ;
M: windows scp-name "pscp" ;

: upload-images ( -- )
    [
        \ scp-name get-global scp-name or ,
        boot-image-names %
        checksums , destination ,
    ] { } make try-process ;

: new-images ( -- )
    [
        make-images
        compute-checksums
        upload-images
    ] with-resource-directory ;

MAIN: new-images
