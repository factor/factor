! Copyright (C) 2018 Alexander Ilin.
! See http://factorcode.org/license.txt for BSD license.
USING: calendar checksums.hmac checksums.sha io.binary kernel
math math.bitwise math.parser namespaces sequences ;
IN: totp

SYMBOLS: totp-hash totp-digits ;
totp-hash [ sha-256 ] initialize
totp-digits [ 6 ] initialize

<PRIVATE

: totp-value ( hash-bytes -- n )
    [ last 4 bits dup 4 + ] keep <slice> be> 31 clear-bit ;

PRIVATE>

: timestamp>count* ( timestamp secs/count -- count )
    [ timestamp>unix-time ] dip /i 8 >be ; inline

: timestamp>count ( timestamp -- count )
    30 timestamp>count* ;

: totp* ( count key hash -- n )
    hmac-bytes totp-value ;

: digits ( n digits -- string )
    [ number>string ] dip [ CHAR: 0 pad-head ] keep tail* ;

: totp ( key -- string )
    now timestamp>count swap totp-hash get totp* totp-digits get digits ;
