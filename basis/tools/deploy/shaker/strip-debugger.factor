USING: compiler.units words vocabs kernel threads.private ;
IN: debugger

: print-error ( error -- ) die drop ;

: error. ( error -- ) die drop ;

"threads" vocab [
    [
        "error-in-thread" "threads" lookup
        [ die 2drop ]
        define
    ] with-compilation-unit
] when
