USING: accessors assocs continuations effects io
io.encodings.binary io.servers.connection kernel
memoize namespaces parser sets sequences serialize
threads vocabs vocabs.parser words ;

IN: modules.rpc-server

SYMBOL: serving-vocabs V{ } clone serving-vocabs set-global

: do-rpc ( args word -- bytes )
   [ execute ] curry with-datastack object>bytes ; inline

MEMO: mem-do-rpc ( args word -- bytes ) do-rpc ; inline

: process ( vocabspec -- ) vocab-words [ deserialize ] dip deserialize
   swap at "executer" get execute( args word -- bytes ) write flush ;

: (serve) ( -- ) deserialize dup serving-vocabs get-global index
   [ process ] [ drop ] if ;

: start-serving-vocabs ( -- ) [
   <threaded-server> 5000 >>insecure binary >>encoding [ (serve) ] >>handler
   start-server ] in-thread ;

: (service) ( -- ) serving-vocabs get-global empty? [ start-serving-vocabs ] when
   current-vocab serving-vocabs get-global adjoin
   "get-words" create-in
   in get [ vocab vocab-words [ stack-effect ] { } assoc-map-as ] curry
   (( -- words )) define-inline ;

SYNTAX: service \ do-rpc  "executer" set (service) ;
SYNTAX: mem-service \ mem-do-rpc "executer" set (service) ;

load-vocab-hook [
   [ dup words>> values
   \ mem-do-rpc "memoize" word-prop [ delete-at ] curry each ]
append ] change-global