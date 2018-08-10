! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors byte-arrays byte-vectors
combinators.short-circuit fry io.binary kernel locals math
math.bitwise sequences sequences.private ;
IN: bitstreams

TUPLE: widthed
{ bits integer read-only }
{ n-bits integer read-only } ;

ERROR: invalid-widthed bits n-bits ;

: check-widthed ( bits n-bits -- bits n-bits )
    2dup {
        [ nip 0 < ]
        [ { [ nip 0 = ] [ drop 0 = not ] } 2&& ]
        [
            swap [ drop f ] [
                dup 0 < [ neg ] when log2 <=
            ] if-zero
        ]
    } 2|| [ invalid-widthed ] when ;

: <widthed> ( bits n-bits -- widthed )
    check-widthed
    widthed boa ;

: zero-widthed ( -- widthed ) 0 0 <widthed> ;

: zero-widthed? ( widthed -- ? ) zero-widthed = ;

TUPLE: bit-reader
    { bytes byte-array }
    { byte-pos array-capacity initial: 0 }
    { bit-pos array-capacity initial: 0 } ;

TUPLE: msb0-bit-reader < bit-reader ;
TUPLE: lsb0-bit-reader < bit-reader ;

: <msb0-bit-reader> ( bytes -- bs )
    msb0-bit-reader new swap >>bytes ; inline

: <lsb0-bit-reader> ( bytes -- bs )
    lsb0-bit-reader new swap >>bytes ; inline

TUPLE: bit-writer
    { bytes byte-vector }
    { widthed widthed } ;

TUPLE: msb0-bit-writer < bit-writer ;
TUPLE: lsb0-bit-writer < bit-writer ;

: new-bit-writer ( class -- bs )
    new
        BV{ } clone >>bytes
        zero-widthed >>widthed ; inline

: <msb0-bit-writer> ( -- bs )
    msb0-bit-writer new-bit-writer ;

: <lsb0-bit-writer> ( -- bs )
    lsb0-bit-writer new-bit-writer ;

GENERIC: peek ( n bitstream -- value )
GENERIC: poke ( value n bitstream -- )

: get-abp ( bitstream -- abp )
    [ byte-pos>> 8 * ] [ bit-pos>> + ] bi ; inline

: set-abp ( abp bitstream -- )
    [ 8 /mod ] dip [ bit-pos<< ] [ byte-pos<< ] bi ; inline

: seek ( n bitstream -- )
    [ get-abp + ] [ set-abp ] bi ; inline

: (align) ( n m -- n' )
    [ /mod 0 > [ 1 + ] when ] [ * ] bi ; inline

: align ( n bitstream -- )
    [ get-abp swap (align) ] [ set-abp ] bi ; inline

: read ( n bitstream -- value )
    [ peek ] [ seek ] 2bi ; inline

<PRIVATE

ERROR: not-enough-widthed-bits widthed n ;

: check-widthed-bits ( widthed n -- widthed n )
    2dup { [ nip 0 < ] [ [ n-bits>> ] dip < ] } 2||
    [ not-enough-widthed-bits ] when ;

: widthed-bits ( widthed n -- bits )
    check-widthed-bits
    [ [ bits>> ] [ n-bits>> ] bi ] dip
    [ - neg shift ] keep <widthed> ;

: split-widthed ( widthed n -- widthed1 widthed2 )
    2dup [ n-bits>> ] dip < [
        drop zero-widthed
    ] [
        [ widthed-bits ]
        [ [ [ bits>> ] [ n-bits>> ] bi ] dip - [ bits ] keep <widthed> ] 2bi
    ] if ;

: widthed>bytes ( widthed -- bytes widthed )
    [ 8 split-widthed dup zero-widthed? not ]
    [ swap bits>> ] B{ } produce-as nip swap ;

:: |widthed ( widthed1 widthed2 -- widthed3 )
    widthed1 bits>> :> bits1
    widthed1 n-bits>> :> n-bits1
    widthed2 bits>> :> bits2
    widthed2 n-bits>> :> n-bits2
    bits1 n-bits2 shift bits2 bitor
    n-bits1 n-bits2 + <widthed> ;

PRIVATE>

M:: lsb0-bit-writer poke ( value n bs -- )
    value n <widthed> :> widthed
    widthed
    bs widthed>> n-bits>> 8 swap - split-widthed :> ( byte remainder )
    byte bs widthed>> |widthed :> new-byte
    new-byte n-bits>> 8 = [
        new-byte bits>> bs bytes>> push
        zero-widthed bs widthed<<
        remainder widthed>bytes
        [ bs bytes>> push-all ] [ bs widthed<< ] bi*
    ] [
        byte bs widthed<<
    ] if ;

: enough-bits? ( n bs -- ? )
    [ bytes>> length ]
    [ byte-pos>> - 8 * ]
    [ bit-pos>> - ] tri <= ;

ERROR: not-enough-bits n bit-reader ;

: n-bits>n-bytes ( n-bits -- n-bytes )
    8 /mod 0 = [ 1 + ] unless ; inline

:: subseq>bits-le ( bignum n bs -- bits )
    bignum bs bit-pos>> neg shift n bits ;

:: subseq>bits-be ( bignum n bs -- bits )
    bignum
    8 bs bit-pos>> - n - 8 mod dup 0 < [ 8 + ] when
    neg shift n bits ;

:: adjust-bits ( n bs -- )
    n 8 /mod :> ( n-bytes n-bits )
    bs [ n-bytes + ] change-byte-pos
    bit-pos>> n-bits + dup 8 >= [
        8 - bs bit-pos<<
        bs [ 1 + ] change-byte-pos drop
    ] [
        bs bit-pos<<
    ] if ;

:: (peek) ( n bs endian> subseq-endian -- bits )
    n bs enough-bits? [ n bs not-enough-bits ] unless
    bs [ byte-pos>> ] [ bit-pos>> n + ] bi n-bits>n-bytes dupd +
    bs bytes>> subseq endian> execute( seq -- x )
    n bs subseq-endian execute( bignum n bs -- bits ) ;

M: lsb0-bit-reader peek ( n bs -- bits )
    \ le> \ subseq>bits-le (peek) ;

M: msb0-bit-reader peek ( n bs -- bits )
    \ be> \ subseq>bits-be (peek) ;

:: bit-writer-bytes ( writer -- bytes )
    writer widthed>> n-bits>> :> n
    n 0 = [
        writer widthed>> bits>> 8 n - shift
        writer bytes>> push
    ] unless
    writer bytes>> ;

:: byte-array-n>sequence ( byte-array n -- seq )
    byte-array length 8 * n / <iota>
    byte-array <msb0-bit-reader> '[
        drop n _ read
    ] { } map-as ;
