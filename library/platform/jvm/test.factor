IN: test
USE: combinators
USE: compiler
USE: namespaces
USE: stdio
USE: stack
USE: test
USE: words

: must-compile ( word -- )
    "compile" get [
        "Checking if " write dup write " was compiled" print
        dup compile
        worddef compiled? assert
    ] [
        drop
    ] ifte ;
