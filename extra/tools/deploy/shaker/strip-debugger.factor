USING: kernel threads threads.private ;
IN: debugger

: print-error die ;

: error. die ;

M: thread error-in-thread ( error thread -- ) die 2drop ;
