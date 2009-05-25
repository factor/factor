USING: assocs modules.rpc-server vocabs
modules.remote-loading words ;
IN: modules.uploads service

: upload-vocab ( word binary -- ) \ get-vocab "memoize" word-prop set-at ;