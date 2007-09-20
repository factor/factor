USING: arrays combinators crypto.common crypto.md5 crypto.sha1
crypto.md5.private io io.binary io.files io.streams.string
kernel math math.vectors memoize sequences ;
IN: crypto.hmac

: sha1-hmac ( Ko Ki -- hmac )
    initialize-sha1 process-sha1-block
    (stream>sha1) get-sha1
    initialize-sha1
    >r process-sha1-block r>
    process-sha1-block get-sha1 ;

: md5-hmac ( Ko Ki -- hmac )
    initialize-md5 process-md5-block
    (stream>md5) get-md5
    initialize-md5
    >r process-md5-block r>
    process-md5-block get-md5 ;

: seq-bitxor ( seq seq -- seq )
    [ bitxor ] 2map ;

MEMO: ipad ( -- seq ) 64 HEX: 36 <array> ;
MEMO: opad ( -- seq ) 64 HEX: 5c <array> ;

: init-hmac ( K -- o i )
    64 0 pad-right 
    [ opad seq-bitxor ] keep
    ipad seq-bitxor ;

: stream>sha1-hmac ( K stream -- hmac )
    [ init-hmac sha1-hmac ] with-stream ;

: file>sha1-hmac ( K path -- hmac )
    <file-reader> stream>sha1-hmac ;

: string>sha1-hmac ( K string -- hmac )
    <string-reader> stream>sha1-hmac ;


: stream>md5-hmac ( K stream -- hmac )
    [ init-hmac md5-hmac ] with-stream ;

: file>md5-hmac ( K path -- hmac )
    <file-reader> stream>md5-hmac ;

: string>md5-hmac ( K string -- hmac )
    <string-reader> stream>md5-hmac ;

