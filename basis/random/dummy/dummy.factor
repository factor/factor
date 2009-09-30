USING: kernel math accessors random ;
IN: random.dummy

TUPLE: random-dummy i ;
C: <random-dummy> random-dummy

M: random-dummy seed-random ( obj seed -- obj )
    >>i ;

M: random-dummy random-32 ( obj -- r )
    [ dup 1 + ] change-i drop ;
