USING: accessors classes.struct fry io io.encodings.binary io.files
io.streams.byte-array kernel math sequences
tools.image.analyzer.code-heap-reader
tools.image.analyzer.data-heap-reader tools.image.analyzer.utils
tools.image.analyzer.vm ;
IN: tools.image.analyzer

TUPLE: image header heap ;

: code-heap>code-blocks ( code-heap -- code-blocks )
    binary [ [ read-code-block ] consume-stream>sequence ] with-byte-reader ;

: data-heap-size ( header-struct -- data-heap-size )
    [ escaped-data-size>> ] [ data-size>> ] bi [ nip ] unless-zero ;

: data-heap>objects ( data-relocation-base data-heap -- seq )
    binary [ '[ _ read-object ] consume-stream>sequence ] with-byte-reader ;

: (adjust-addresses) ( nodes base -- )
    '[ [ _ + ] change-address drop ] each ;

: adjust-addresses ( header data-nodes code-nodes -- )
    pick code-relocation-base>> (adjust-addresses)
    swap data-relocation-base>> (adjust-addresses) ;

ERROR: unsupported-image-format ;

: compressed-data? ( header -- ? ) [ data-heap-size ] [ compressed-data-size>> ] bi [ dup ] when-zero = not ;
: compressed-code? ( header -- ? ) [ code-size>>    ] [ compressed-code-size>> ] bi [ dup ] when-zero = not ;

: check-uncompressed ( header -- header/* )
    [ [ compressed-data? ] [ compressed-code? ] bi or [ unsupported-image-format ] when ] keep ;

: load-image ( image-file -- image )
    binary [
        image-header read-struct check-uncompressed dup [
            [ data-relocation-base>> ] [ data-heap-size read ] bi
            data-heap>objects
        ]
        [ code-size>> read code-heap>code-blocks ] bi
    ] with-file-reader 3dup adjust-addresses append image boa ;
