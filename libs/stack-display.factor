USING: kernel errors io namespaces tools ;
IN: listener

SYMBOL: stack-display

: (print-stacks) ( -- )
    "----------" print .s "----------" print .r ;

: print-stacks ( -- )
    stack-display get [ (print-stacks) ] when ;

: listen ( -- )
    [
        stdio get parse-interactive
        [ call print-stacks ] [ bye ] if*
    ] try ;

t stack-display set-global

PROVIDE: libs/stack-display ;