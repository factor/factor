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
CONSTRUCTOR: msb0-bit-writer ( -- bs )
    BV{ } clone >>bytes
    0 0 <widthed> >>widthed ;
CONSTRUCTOR: lsb0-bit-writer ( -- bs )
    BV{ } clone >>bytes
    0 0 <widthed> >>widthed ;

! interface

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


! reading

<PRIVATE

MACRO: multi-alien-unsigned-1 ( seq -- quot ) 
    [ '[ _ + alien-unsigned-1 ] ] map 2cleave>quot ;

GENERIC: fetch3-le-unsafe ( n byte-array -- value )
GENERIC: fetch3-be-unsafe ( n byte-array -- value )

: fetch3-unsafe ( byte-array n offsets -- value ) 
    multi-alien-unsigned-1 8 2^ * + 8 2^ * + ; inline

M: byte-array fetch3-le-unsafe ( n byte-array -- value ) 
    swap { 0 1 2 } fetch3-unsafe ; inline
M: byte-array fetch3-be-unsafe ( n byte-array -- value ) 
    swap { 2 1 0 } fetch3-unsafe ; inline

: fetch3 ( n byte-array -- value ) 
    [ 3 [0,b) [ + ] with map ] dip [ nth ] curry map ;
    
: fetch3-le ( n byte-array -- value ) fetch3 le> ;
: fetch3-be ( n byte-array -- value ) fetch3 be> ;
    
GENERIC: peek16 ( n bitstream -- value )

M:: lsb0-bit-reader peek16 ( n bs -- v )
    bs byte-pos>> bs bytes>> fetch3-le
    bs bit-pos>> 2^ /i
    n 2^ mod ;

M:: msb0-bit-reader peek16 ( n bs -- v )
    bs byte-pos>> bs bytes>> fetch3-be
    24 n bs bit-pos>> + - 2^ /i
    n 2^ mod ;

PRIVATE>

M: lsb0-bit-reader peek ( n bs -- v ) peek16 ;
M: msb0-bit-reader peek ( n bs -- v ) peek16 ;

! writing

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

PRIVATE>

M:: lsb0-bit-writer poke ( value n bs -- )
    value n <widthed> :> widthed
    widthed
    bs widthed>> #bits>> 8 swap - split-widthed :> remainder :> byte

    byte #bits>> 8 = [
        byte bits>> bs bytes>> push
        zero-widthed bs (>>widthed)
        remainder widthed>bytes
        [ bs bytes>> push-all ] [ B bs (>>widthed) ] bi*
    ] [
        byte bs (>>widthed)
    ] if ;
