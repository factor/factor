USING: kernel math accessors random ;
IN: random.dummy

TUPLE: random-dummy i ;
C: <random-dummy> random-dummy

M: random-dummy seed-random
    >>i ;

M: random-dummy random-32*
    [ dup 1 + ] change-i drop ;

INSTANCE: random-dummy base-random
