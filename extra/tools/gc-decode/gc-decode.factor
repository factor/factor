USING: accessors alien alien.c-types alien.data arrays assocs bit-arrays
bit-arrays.private classes.struct fry grouping kernel math math.statistics
sequences sequences.repeating splitting vm words ;
IN: tools.gc-decode

! Utils
: byte-array>bit-array ( byte-array -- bit-array )
    [ integer>bit-array 8 f pad-tail ] { } map-as concat ;

: (cut-points) ( counts times -- seq )
    <repeats> cum-sum but-last ;

: reshape-sequence ( seq counts times -- seqs )
    [ (cut-points) split-indices ] keep <groups> flip ;

: end-address>direct-array ( obj count type -- seq )
    [ heap-size * [ >c-ptr alien-address ] dip - <alien> ] 2keep
    c-direct-array-constructor execute( alien len -- seq ) ;

: bit-counts ( gc-info -- counts )
    struct-slot-values 3 head ;

: total-bitmap-bits ( gc-info -- n )
    [ bit-counts sum ] [ return-address-count>> ] bi * ;

: return-addresses ( gc-info -- seq )
    dup return-address-count>> uint end-address>direct-array ;

: base-pointers ( gc-info -- seq )
    [ return-addresses ]
    [ return-address-count>> ]
    [ derived-root-count>> ] tri *
    int end-address>direct-array ;

: base-pointer-groups ( gc-info -- seqs )
    dup base-pointers
    [ return-address-count>> { } <array> ]
    [ swap derived-root-count>> <groups> [ >array ] map ] if-empty ;

: scrub-bytes ( gc-info -- seq )
    [ base-pointers ] [ total-bitmap-bits bits>bytes ] bi
    uchar end-address>direct-array ;

: scrub-bits ( gc-info -- seq )
    [ scrub-bytes byte-array>bit-array ] keep total-bitmap-bits head ;

: scrub-bit-groups ( gc-info -- scrub-groups )
    [ scrub-bits ] [ bit-counts ] [ return-address-count>> ] tri
    [ 2drop { } ] [ reshape-sequence ] if-zero ;

: read-gc-maps ( gc-info -- assoc )
    [ return-addresses ] [ scrub-bit-groups ] [ base-pointer-groups ] tri
    zip zip ;

: word>gc-info ( word -- gc-info )
    word-code nip gc-info struct-size - <alien> gc-info memory>struct ;

: decode-gc-maps ( word -- assoc )
    word>gc-info read-gc-maps ;
