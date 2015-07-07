USING: accessors alien.c-types alien.data arrays assocs
bit-arrays.private classes.struct fry grouping io io.encodings.binary
io.streams.byte-array kernel math math.statistics sequences
sequences.repeating splitting tools.image-analyzer.utils vm ;
IN: tools.image-analyzer.gc-info

! Utils
: read-ints ( count -- seq )
    int read-array ;

: read-bits ( bit-count -- bit-array )
    [ bits>bytes read byte-array>bit-array ] keep head ;

: (cut-points) ( counts times -- seq )
    <repeats> cum-sum but-last ;

: reshape-sequence ( seq counts times -- seqs )
    [ (cut-points) split-indices ] keep <groups> flip ;

: read-struct-safe ( struct -- instance/f )
    dup heap-size read [ swap memory>struct ] [ drop f ] if* ;

! Real stuff
: return-addresses ( gc-info -- seq )
    return-address-count>> read-ints ;

: base-pointers ( gc-info -- seq )
    [ return-address-count>> ] keep derived-root-count>>
    '[ _ read-ints ] replicate ;

: bit-counts ( gc-info -- counts )
    struct-slot-values 3 head ;

: (read-scrub-bits) ( gc-info -- seq )
    [ bit-counts sum ] [ return-address-count>> ] bi * read-bits ;

: scrub-bits ( gc-info -- seq )
    [ (read-scrub-bits) ] [ bit-counts ] [ return-address-count>> ] tri
    [ 2drop { } ] [ reshape-sequence ] if-zero ;

: byte-array>gc-maps ( byte-array -- gc-maps )
    binary <byte-reader> <backwards-reader> [
        gc-info read-struct-safe [
            [ return-addresses ] [ base-pointers ] [ scrub-bits ] tri
            swap zip zip
        ] [ { } ] if*
    ] with-input-stream ;
