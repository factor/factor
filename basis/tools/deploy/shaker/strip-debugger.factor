USING: compiler.units continuations kernel namespaces
threads.private words vocabs tools.deploy.shaker ;
IN: debugger

: error. ( error -- ) original-error get die-with2 ;

: print-error ( error -- ) error. ;

"threads" vocab [
    [
        "error-in-thread" "threads" lookup
        [ [ drop error. ] define ] [ f "combination" set-word-prop ] bi
    ] with-compilation-unit
] when
