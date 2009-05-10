! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays kernel kernel.private math sequences
sequences.private growable byte-arrays accessors ;
IN: byte-vectors

TUPLE: byte-vector
{ underlying byte-array }
{ length array-capacity } ;

: <byte-vector> ( n -- byte-vector )
    (byte-array) 0 byte-vector boa ; inline

: >byte-vector ( seq -- byte-vector )
    T{ byte-vector f B{ } 0 } clone-like ;

M: byte-vector like
    drop dup byte-vector? [
        dup byte-array?
        [ dup length byte-vector boa ] [ >byte-vector ] if
    ] unless ;

M: byte-vector new-sequence
    drop [ (byte-array) ] [ >fixnum ] bi byte-vector boa ;

M: byte-vector equal?
    over byte-vector? [ sequence= ] [ 2drop f ] if ;

M: byte-array like
    #! If we have an byte-array, we're done.
    #! If we have a byte-vector, and it's at full capacity,
    #! we're done. Otherwise, call resize-byte-array, which is a
    #! relatively fast primitive.
    drop dup byte-array? [
        dup byte-vector? [
            [ length ] [ underlying>> ] bi
            2dup length eq?
            [ nip ] [ resize-byte-array ] if
        ] [ >byte-array ] if
    ] unless ;

M: byte-array new-resizable drop <byte-vector> ;

INSTANCE: byte-vector growable
