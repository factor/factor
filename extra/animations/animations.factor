! Small library for cross-platform continuous functions of real time

USING: kernel shuffle system locals
prettyprint math io namespaces threads calendar ;
IN: animations

SYMBOL: last-loop
SYMBOL: sleep-period

: reset-progress ( -- ) millis last-loop set ;
: progress ( -- progress ) millis last-loop get - reset-progress ;
: set-end ( duration -- end-time ) dt>milliseconds millis + ;
: loop ( quot end -- ) dup millis > [ [ dup call ] dip loop ] [ 2drop ] if ; inline
: animate ( quot duration -- ) reset-progress set-end loop ; inline
: sample ( revs quot -- avg ) reset-progress dupd times progress swap / ; inline