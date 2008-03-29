USING: kernel random math accessors  ;
IN: random.dummy

TUPLE: random-dummy i ;
C: <random-dummy> random-dummy

M: random-dummy seed-random ( seed obj -- )
    (>>i) ;

M: random-dummy random-32* ( obj -- r )
    [ dup 1+ ] change-i drop ;
