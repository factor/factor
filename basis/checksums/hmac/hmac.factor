! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays checksums checksums.md5 checksums.md5.private
checksums.sha1 combinators fry io io.binary io.encodings.binary
io.files io.streams.byte-array kernel math math.vectors memoize
sequences ;
IN: checksums.hmac

<PRIVATE

/*
: sha1-hmac ( Ko Ki stream -- hmac )
    initialize-sha1 process-sha1-block
    stream>sha1 get-sha1
    initialize-sha1
    [ process-sha1-block ]
    [ process-sha1-block ] bi* get-sha1 ;

 : md5-hmac ( Ko Ki stream -- hmac )
    initialize-md5 process-md5-block
    stream>md5 get-md5
    initialize-md5
    [ process-md5-block ]
    [ process-md5-block ] bi* get-md5 ;
*/

: seq-bitxor ( seq seq -- seq ) [ bitxor ] 2map ;

MEMO: opad ( -- seq ) 64 HEX: 5c <array> ;

MEMO: ipad ( -- seq ) 64 HEX: 36 <array> ;

: init-K ( K -- o i )
    64 0 pad-tail 
    [ opad seq-bitxor ]
    [ ipad seq-bitxor ] bi ;

PRIVATE>

:: hmac-stream ( K stream checksum -- value )
    K init-K :> Ki :> Ko
    checksum initialize-checksum
    Ki add-bytes
    stream add-stream finish-checksum
    checksum initialize-checksum
    Ko add-bytes swap add-bytes
    finish-checksum ;

: hmac-file ( K path checksum -- value )
    [ binary <file-reader> ] dip hmac-stream ;

: hmac-bytes ( K seq checksum -- value )
    [ binary <byte-reader> ] dip hmac-stream ;
