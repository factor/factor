! Copyright (C) 2006 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs kernel io io.files namespaces serialize ;
IN: store.blob

: (save-blob) serialize ;

: save-blob ( obj path -- )
    <file-appender> [ (save-blob) ] with-stream ;

: (load-blob) ( path -- seq/f )
    dup exists? [
        <file-reader> [
            [ deserialize-sequence ] with-serialized
        ] with-stream
    ] [
        drop f
    ] if ;

: load-blob ( path -- seq/f )
    resource-path (load-blob) ;

