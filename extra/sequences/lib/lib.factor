USING: combinators.lib kernel sequences math
sequences.private shuffle ;

IN: sequences.lib

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: map-reduce ( seq map-quot reduce-quot -- result )
    >r [ unclip ] dip [ call ] keep r> compose reduce ; inline

: reduce* ( seq quot -- result ) [ ] swap map-reduce ; inline

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: higher ( a b quot -- c ) [ compare 0 > ] curry most ; inline

: lower  ( a b quot -- c ) [ compare 0 < ] curry most ; inline

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: longer  ( a b -- c ) [ length ] higher ;

: shorter ( a b -- c ) [ length ] lower ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: longest ( seq -- item ) [ longer ] reduce* ;

: shortest ( seq -- item ) [ shorter ] reduce* ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: bigger ( a b -- c ) [ ] higher ;

: smaller ( a b -- c ) [ ] lower ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: biggest ( seq -- item ) [ bigger ] reduce* ;

: smallest ( seq -- item ) [ smaller ] reduce* ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: minmax ( seq -- min max )
    #! find the min and max of a seq in one pass
    1/0. -1/0. rot [ tuck max >r min r> ] each ;

