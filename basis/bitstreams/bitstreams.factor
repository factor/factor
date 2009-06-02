! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.accessors assocs byte-arrays combinators
constructors destructors fry io io.binary io.encodings.binary
io.streams.byte-array kernel locals macros math math.ranges
multiline sequences sequences.private vectors byte-vectors
combinators.short-circuit math.bitwise ;
IN: bitstreams

TUPLE: widthed { bits integer read-only } { #bits integer read-only } ;

ERROR: invalid-widthed bits #bits ;

: check-widthed ( bits #bits -- bits #bits )
    dup 0 < [ invalid-widthed ] when
    2dup { [ nip 0 = ] [ drop 0 = not ] } 2&& [ invalid-widthed ] when
    over 0 = [
        2dup [ dup 0 < [ neg ] when log2 1 + ] dip > [ invalid-widthed ] when
    ] unless ;

: <widthed> ( bits #bits -- widthed )
    check-widthed
    widthed boa ;

: zero-widthed ( -- widthed ) 0 0 <widthed> ;
: zero-widthed? ( widthed -- ? ) zero-widthed = ;

TUPLE: bit-reader
    { bytes byte-array }
    { byte-pos array-capacity initial: 0 }
    { bit-pos array-capacity initial: 0 } ;

TUPLE: bit-writer
    { bytes byte-vector }
    { widthed widthed } ;

TUPLE: msb0-bit-reader < bit-reader ;
TUPLE: lsb0-bit-reader < bit-reader ;
CONSTRUCTOR: msb0-bit-reader ( bytes -- bs ) ;
CONSTRUCTOR: lsb0-bit-reader ( bytes -- bs ) ;

TUPLE: msb0-bit-writer < bit-writer ;
TUPLE: lsb0-bit-writer < bit-writer ;

: new-bit-writer ( class -- bs )
    new
        BV{ } clone >>bytes
        0 0 <widthed> >>widthed ; inline

: <msb0-bit-writer> ( -- bs )
    msb0-bit-writer new-bit-writer ;

: <lsb0-bit-writer> ( -- bs )
    lsb0-bit-writer new-bit-writer ;

GENERIC: peek ( n bitstream -- value )
GENERIC: poke ( value n bitstream -- )

: seek ( n bitstream -- )
    {
        [ byte-pos>> 8 * ]
        [ bit-pos>> + + 8 /mod ]
        [ (>>bit-pos) ]
        [ (>>byte-pos) ]
    } cleave ; inline

: read ( n bitstream -- value )
    [ peek ] [ seek ] 2bi ; inline

<PRIVATE

ERROR: not-enough-bits widthed n ;

: widthed-bits ( widthed n -- bits )
    dup 0 < [ not-enough-bits ] when
    2dup [ #bits>> ] dip < [ not-enough-bits ] when
    [ [ bits>> ] [ #bits>> ] bi ] dip
    [ - neg shift ] keep <widthed> ;

: split-widthed ( widthed n -- widthed1 widthed2 )
    2dup [ #bits>> ] dip < [
        drop zero-widthed
    ] [
        [ widthed-bits ]
        [ [ [ bits>> ] [ #bits>> ] bi ] dip - [ bits ] keep <widthed> ] 2bi
    ] if ;

: widthed>bytes ( widthed -- bytes widthed )
    [ 8 split-widthed dup zero-widthed? not ]
    [ swap bits>> ] B{ } produce-as nip swap ;

:: |widthed ( widthed1 widthed2 -- widthed3 )
    widthed1 bits>> :> bits1
    widthed1 #bits>> :> #bits1
    widthed2 bits>> :> bits2
    widthed2 #bits>> :> #bits2
    bits1 #bits2 shift bits2 bitor
    #bits1 #bits2 + <widthed> ;

PRIVATE>

M:: lsb0-bit-writer poke ( value n bs -- )
    value n <widthed> :> widthed
    widthed
    bs widthed>> #bits>> 8 swap - split-widthed :> remainder :> byte
    byte bs widthed>> |widthed :> new-byte
    new-byte #bits>> 8 = [
        new-byte bits>> bs bytes>> push
        zero-widthed bs (>>widthed)
        remainder widthed>bytes
        [ bs bytes>> push-all ] [ bs (>>widthed) ] bi*
    ] [
        byte bs (>>widthed)
    ] if ;

: enough-bits? ( n bs -- ? )
    [ bytes>> length ]
    [ byte-pos>> - 8 * ]
    [ bit-pos>> - ] tri <= ;

ERROR: not-enough-bits n bit-reader ;

: #bits>#bytes ( #bits -- #bytes )
    8 /mod 0 = [ 1 + ] unless ; inline

:: subseq>bits-le ( bignum n bs -- bits )
    bignum bs bit-pos>> neg shift n bits ;

:: subseq>bits-be ( bignum n bs -- bits )
    bignum 
    8 bs bit-pos>> - n - 8 mod dup 0 < [ 8 + ] when
    neg shift n bits ;

:: adjust-bits ( n bs -- )
    n 8 /mod :> #bits :> #bytes
    bs [ #bytes + ] change-byte-pos
    bit-pos>> #bits + dup 8 >= [
        8 - bs (>>bit-pos)
        bs [ 1 + ] change-byte-pos drop
    ] [
        bs (>>bit-pos)
    ] if ;

:: (peek) ( n bs endian> subseq-endian -- bits )
    n bs enough-bits? [ n bs not-enough-bits ] unless
    bs [ byte-pos>> ] [ bit-pos>> n + ] bi #bits>#bytes dupd +
    bs bytes>> subseq endian> execute( seq -- x ) :> bignum
    bignum n bs subseq-endian execute( bignum n bs -- bits ) ;

M: lsb0-bit-reader peek ( n bs -- bits ) \ le> \ subseq>bits-le (peek) ;

M: msb0-bit-reader peek ( n bs -- bits ) \ be> \ subseq>bits-be (peek) ;

:: bit-writer-bytes ( writer -- bytes )
    writer widthed>> #bits>> :> n
    n 0 = [
        writer widthed>> bits>> 8 n - shift
        writer bytes>> swap push
    ] unless
    writer bytes>> ;
