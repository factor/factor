USING: compiler.units words vocabs kernel threads.private ;
IN: debugger

: consume ( error -- )
    #! We don't want DCE to drop the error before the die call!
    drop ;

: print-error ( error -- ) die consume ;

: error. ( error -- ) die consume ;

"threads" vocab [
    [
        "error-in-thread" "threads" lookup
        [ [ die 2drop ] define ] [ f "combination" set-word-prop ] bi
    ] with-compilation-unit
] when
