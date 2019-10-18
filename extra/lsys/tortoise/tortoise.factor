
USING: kernel generic math arrays
       math.matrices generic.lib pos ori self turtle ;

IN: lsys.tortoise

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: tortoise angle len thickness color ;

: <tortoise> ( -- tortoise )
    <turtle> tortoise construct-delegate ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: angle> ( -- val ) self> tortoise-angle ;

: >angle ( val -- ) self> set-tortoise-angle ;

: len> ( -- val ) self> tortoise-len ;

: >len ( val -- ) self> set-tortoise-len ;

: thickness> ( -- val ) self> tortoise-thickness ;

: >thickness ( val -- ) self> set-tortoise-thickness ;

: color> ( -- val ) self> tortoise-color ;

: >color ( val -- ) self> set-tortoise-color ;

