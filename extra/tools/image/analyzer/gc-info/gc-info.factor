USING: accessors alien.c-types assocs bit-arrays.private
classes.struct fry grouping io io.encodings.binary
io.streams.byte-array kernel math sequences tools.image.analyzer.utils
vm ;
IN: tools.image.analyzer.gc-info

! Utils
: read-ints ( count -- seq )
    int read-array ;

: read-bits ( bit-count -- bit-array )
    [ bits>bytes read byte-array>bit-array ] keep head ;

: read-struct-safe ( struct -- instance/f )
    dup heap-size read [ swap memory>struct ] [ drop f ] if* ;

! Real stuff
: return-addresses ( gc-info -- seq )
    return-address-count>> read-ints ;

: base-pointers ( gc-info -- seq )
    [ return-address-count>> ] keep derived-root-count>>
    '[ _ read-ints ] replicate <reversed> ;

: (read-scrub-bits) ( gc-info -- seq )
    [ gc-root-count>> ] [ return-address-count>> ] bi * read-bits ;

: scrub-bits ( gc-info -- seq )
    [ (read-scrub-bits) ] [ gc-root-count>> ] bi
    [ drop { } ] [ group ] if-zero ;

: byte-array>gc-maps ( byte-array -- gc-maps )
    binary <byte-reader> <backwards-reader> [
        gc-info read-struct-safe [
            [ return-addresses ] [ base-pointers ] [ scrub-bits ] tri
            swap zip zip
        ] [ { } ] if*
    ] with-input-stream ;

: word>gc-maps ( word -- gc-maps )
    word>byte-array byte-array>gc-maps ;
