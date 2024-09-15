! Copyright (C) 2011 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: ascii assocs checksums checksums.md5 classes.tuple
formatting hex-strings http.client images.http
io.encodings.string io.encodings.utf8 json kernel namespaces
sequences urls ;

IN: gravatar

TUPLE: info aboutMe accounts currentLocation displayName emails
hash id ims name phoneNumbers photos preferredUsername
profileBackground profileUrl requestHash thumbnailUrl urls ;

: gravatar-id ( email -- gravatar-id )
    [ blank? ] trim >lower md5 checksum-bytes bytes>hex-string ;

: gravatar-info ( email -- info )
    gravatar-id "https://gravatar.com/%s.json" sprintf
    http-get-json nip "entry" of first info from-slots ;

! optional .jpg
SYMBOL: gravatar-image-extension?

! 1px up to 2048px
SYMBOL: gravatar-image-size

! 404, mp, identicon, monsterid, wavatar, retro, robohash, blank
SYMBOL: gravatar-image-type

! g, pg, r, x
SYMBOL: gravatar-image-rating

: gravatar-image-url ( email -- url )
    gravatar-id "https://gravatar.com/avatar/" prepend
    gravatar-image-extension? get [ ".jpg" append ] when >url
    gravatar-image-size get [ "s" set-query-param ] when*
    gravatar-image-type get [ "d" set-query-param ] when*
    gravatar-image-rating get [ "r" set-query-param ] when* ;

: gravatar. ( email -- )
    gravatar-image-url http-image. ;
