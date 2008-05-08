! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: bootstrap.image.download
USING: http.client checksums checksums.md5 splitting assocs
kernel io.files bootstrap.image sequences io ;

: url "http://factorcode.org/images/latest/" ;

: download-checksums ( -- alist )
    url "checksums.txt" append http-get
    string-lines [ " " split1 ] { } map>assoc ;

: need-new-image? ( image -- ? )
    dup exists?
    [ [ md5 checksum-file hex-string ] [ download-checksums at ] bi = not ]
    [ drop t ] if ;

: download-image ( arch -- )
    boot-image-name dup need-new-image? [
        "Downloading " write dup write "..." print
        url prepend download
    ] [
        "Boot image up to date" print
        drop
    ] if ;

: download-my-image ( -- ) my-arch download-image ;

MAIN: download-my-image
