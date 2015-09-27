USING: accessors arrays assocs classes.struct fry io io.encodings.binary
io.files io.streams.byte-array kernel kernel.private math sequences
tools.image-analyzer.code-heap-reader tools.image-analyzer.data-heap-reader
tools.image-analyzer.utils tools.image-analyzer.vm vm ;
IN: tools.image-analyzer

: code-heap>code-blocks ( code-heap -- code-blocks )
    binary [ [ read-code-block ] consume-stream>sequence ] with-byte-reader ;

: data-heap>objects ( data-relocation-base data-heap -- object-assoc )
    binary [ '[ _ read-object ] consume-stream>sequence ] with-byte-reader ;

: load-image ( image -- header data-heap code-heap )
    binary [
        image-header read-struct dup [
            [ data-relocation-base>> ] [ data-size>> read ] bi
            data-heap>objects
        ]
        [ code-size>> read code-heap>code-blocks ] bi
    ] with-file-reader ;
