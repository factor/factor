! Copyright (C) 2006 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: io namespaces serialize kernel hashtables ;
IN: wee-url-responder

: save-fstore ( variable path -- )
    <file-writer> [ [ get serialize ] with-serialized ] with-stream ;

: load-fstore ( variable path -- )
    dup exists? [
        <file-reader> [ [ deserialize ] with-serialized ] with-stream swap
    ] [
        drop >r H{ } clone r>
    ] if set-global ;

: fstore-set ( variable fstore -- )
    get >r [ get ] keep r> set-hash ;

: fstore-get ( default variable fstore -- )
    get dupd hash* [ swap set-global drop ] [ drop set-global ] if ;
