USING: accessors assocs effects generalizations io
io.encodings.binary io.servers.connection kernel modules.util
namespaces parser sets sequences serialize threads vocabs
vocabs.parser words tools.walker ;

IN: modules.rpc-server

SYMBOL: serving-vocabs V{ } clone serving-vocabs set-global

: process ( vocabspec -- ) vocab-words [ deserialize-args ] dip deserialize
   swap at [ execute ] keep stack-effect out>> length narray serialize flush ;

: (serve) ( -- ) deserialize dup serving-vocabs get-global index
   [ process ] [ f ] if ;

: start-serving-vocabs ( -- ) [
   <threaded-server> 5000 >>insecure binary >>encoding [ (serve) ] >>handler
   start-server ] in-thread ;

SYNTAX: service serving-vocabs get-global empty? [ start-serving-vocabs ] when
   current-vocab serving-vocabs get-global adjoin
   "get-words" create-in
   in get [ vocab vocab-words [ stack-effect ] { } assoc-map-as ] curry
   (( -- words )) define-inline ;