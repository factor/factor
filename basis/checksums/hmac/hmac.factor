! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays checksums combinators fry io io.binary
io.encodings.binary io.files io.streams.byte-array kernel
locals math math.vectors memoize sequences ;
IN: checksums.hmac

<PRIVATE

: seq-bitxor ( seq seq -- seq ) [ bitxor ] 2map ;

: opad ( checksum-state -- seq ) block-size>> HEX: 5c <array> ;

: ipad ( checksum-state -- seq ) block-size>> HEX: 36 <array> ;

:: init-K ( K checksum checksum-state -- o i )
    checksum-state block-size>> K length <
    [ K checksum checksum-bytes ] [ K ] if
    checksum-state block-size>> 0 pad-tail 
    [ checksum-state opad seq-bitxor ]
    [ checksum-state ipad seq-bitxor ] bi ;

PRIVATE>

:: hmac-stream ( K stream checksum -- value )
    K checksum dup initialize-checksum-state
        dup :> checksum-state
        init-K :> Ki :> Ko
    checksum-state Ki add-checksum-bytes
    stream add-checksum-stream get-checksum
    checksum initialize-checksum-state
    Ko add-checksum-bytes swap add-checksum-bytes
    get-checksum ;

: hmac-file ( K path checksum -- value )
    [ binary <file-reader> ] dip hmac-stream ;

: hmac-bytes ( K seq checksum -- value )
    [ binary <byte-reader> ] dip hmac-stream ;
