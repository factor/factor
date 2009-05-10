! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays combinators checksums checksums.md5
checksums.sha1 checksums.md5.private io io.binary io.files
io.streams.byte-array kernel math math.vectors memoize sequences
io.encodings.binary ;
IN: crypto.hmac

<PRIVATE

: sha1-hmac ( Ko Ki -- hmac )
    initialize-sha1 process-sha1-block
    stream>sha1 get-sha1
    initialize-sha1
    [ process-sha1-block ]
    [ process-sha1-block ] bi* get-sha1 ;

: md5-hmac ( Ko Ki -- hmac )
    initialize-md5 process-md5-block
    stream>md5 get-md5
    initialize-md5
    [ process-md5-block ]
    [ process-md5-block ] bi* get-md5 ;

: seq-bitxor ( seq seq -- seq )
    [ bitxor ] 2map ;

MEMO: ipad ( -- seq ) 64 HEX: 36 <array> ;

MEMO: opad ( -- seq ) 64 HEX: 5c <array> ;

: init-hmac ( K -- o i )
    64 0 pad-tail 
    [ opad seq-bitxor ]
    [ ipad seq-bitxor ] bi ;

PRIVATE>

: stream>sha1-hmac ( K stream -- hmac )
    [ init-hmac sha1-hmac ] with-input-stream ;

: file>sha1-hmac ( K path -- hmac )
    binary <file-reader> stream>sha1-hmac ;

: sequence>sha1-hmac ( K sequence -- hmac )
    binary <byte-reader> stream>sha1-hmac ;

: stream>md5-hmac ( K stream -- hmac )
    [ init-hmac md5-hmac ] with-input-stream ;

: file>md5-hmac ( K path -- hmac )
    binary <file-reader> stream>md5-hmac ;

: sequence>md5-hmac ( K sequence -- hmac )
    binary <byte-reader> stream>md5-hmac ;
