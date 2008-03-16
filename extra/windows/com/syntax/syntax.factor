USING: alien alien.c-types kernel windows windows.ole32
combinators.lib parser splitting sequences.lib ;
IN: windows.com.syntax

<PRIVATE

: vtbl ( interface -- vtbl )
    *void* ; inline
: com-invoke ( ... interface n funcptr return parameters -- )
    "stdcall" [
        swap vtbl swap void*-nth
    ] 4 ndip alien-indirect ;

PRIVATE>

: COM-INTERFACE:
    scan
    parse-inheritance
    ";" parse-tokens { ")" } split
    [ 
    ; parsing

