USING: kernel threads threads.private ;
IN: debugger

: print-error ( error -- ) die drop ;

: error. ( error -- ) die drop ;

M: thread error-in-thread ( error thread -- ) die 2drop ;
