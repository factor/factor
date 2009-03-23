! Small library for cross-platform continuous functions of real time

USING: kernel shuffle system locals
prettyprint math io namespaces threads calendar ;
IN: animations

SYMBOL: last-loop
SYMBOL: sleep-period

: reset-progress ( -- ) millis last-loop set ;
! : my-progress ( -- progress ) millis 
: progress ( -- time ) millis last-loop get - reset-progress ;
: progress-peek ( -- progress ) millis last-loop get - ;
: set-end ( duration -- end-time ) duration>milliseconds millis + ;
: loop ( quot end -- ) dup millis > [ [ dup call ] dip loop ] [ 2drop ] if ; inline
: animate ( quot duration -- ) reset-progress set-end loop ; inline
: sample ( revs quot -- avg ) reset-progress dupd times progress swap / ; inline