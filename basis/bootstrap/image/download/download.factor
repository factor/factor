! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: assocs bootstrap.image checksums checksums.md5
http.client http.download io.files kernel math.parser splitting
urls ;
IN: bootstrap.image.download

CONSTANT: download-url URL" https://downloads.factorcode.org/images/master/"

: download-checksums ( -- alist )
    download-url "checksums.txt" >url derive-url http-get nip
    split-lines [ " " split1 ] { } map>assoc ;

: file-checksum ( image -- checksum )
    md5 checksum-file bytes>hex-string ;

: download-checksum ( image -- checksum )
    download-checksums at " " split1 drop ;

: need-new-image? ( image -- ? )
    dup file-exists?
    [ [ file-checksum ] [ download-checksum ] bi = not ]
    [ drop t ]
    if ;

: verify-image ( image -- )
    need-new-image? [ "Boot image corrupt" throw ] when ;

: download-image ( image -- )
    [ download-url ] dip >url derive-url
    download verify-image ;

: maybe-download-image ( image -- ? )
    dup need-new-image? [ download-image t ] [ drop f ] if ;

: download-my-image ( -- )
    my-boot-image-name maybe-download-image drop ;

MAIN: download-my-image
