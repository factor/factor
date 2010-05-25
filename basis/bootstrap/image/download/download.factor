! Copyright (C) 2008, 2010 Slava Pestov.
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

: verify-image ( image -- )
    need-new-image? [ "Boot image corrupt" throw ] when ;

: download-image ( image -- )
    [ url swap >url derive-url download ]
    [ verify-image ]
    bi ;

: maybe-download-image ( image -- ? )
    dup need-new-image?
    [ download-image t ] [ drop f ] if ;

: download-my-image ( -- )
    my-arch boot-image-name maybe-download-image drop ;

MAIN: download-my-image
