IN: algebra USING: prettyprint stdio kernel parser ;

: algebra-repl ( -- )
    "ok " write flush
    read-line dup "exit" = [
        terpri "bye" print
    ] [
        parse infix f swap eval-infix call . algebra-repl
    ] ifte ;
