! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: http.client checksums checksums.md5 splitting assocs
kernel io.files bootstrap.image sequences io urls ;
IN: bootstrap.image.download

CONSTANT: url URL" http://factorcode.org/images/latest/"

: download-checksums ( -- alist )
    url "checksums.txt" >url derive-url http-get nip
    string-lines [ " " split1 ] { } map>assoc ;

: need-new-image? ( image -- ? )
    dup exists?
    [
        [ md5 checksum-file hex-string ]
        [ download-checksums at ]
        bi = not
    ] [ drop t ] if ;

: download-image ( arch -- )
    boot-image-name dup need-new-image? [
        "Downloading " write dup write "..." print
         url over >url derive-url download
         need-new-image? [
             "Boot image corrupt, or checksums.txt on server out of date" throw
         ] when
    ] [
        "Boot image up to date" print
        drop
    ] if ;

: download-my-image ( -- ) my-arch download-image ;

MAIN: download-my-image
