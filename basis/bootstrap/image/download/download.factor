! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs bootstrap.image checksums checksums.md5
http.client io.files kernel math.parser splitting urls ;
IN: bootstrap.image.download

CONSTANT: url URL" http://downloads.factorcode.org/images/master/"

: download-checksums ( -- alist )
    url "checksums.txt" >url derive-url http-get nip
    string-lines [ " " split1 ] { } map>assoc ;

: file-checksum ( image -- checksum )
    md5 checksum-file bytes>hex-string ;

: download-checksum ( image -- checksum )
    download-checksums at ;

: need-new-image? ( image -- ? )
    dup exists?
    [ [ file-checksum ] [ download-checksum ] bi = not ]
    [ drop t ]
    if ;

: verify-image ( image -- )
    need-new-image? [ "Boot image corrupt" throw ] when ;

: download-image ( image -- )
    [ url swap >url derive-url download ]
    [ verify-image ]
    bi ;

: maybe-download-image ( image -- ? )
    dup need-new-image? [ download-image t ] [ drop f ] if ;

: download-my-image ( -- )
    my-boot-image-name maybe-download-image drop ;

MAIN: download-my-image
