
USING: kernel math math.vectors sequences self ;

IN: pos

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: pos val ;

C: <pos> pos

: pos> ( -- val ) self> pos-val ;

: >pos ( val -- ) self> set-pos-val ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: distance ( pos pos -- n ) pos-val swap pos-val v- [ sq ] map sum sqrt ;

: move-by ( point -- ) pos> v+ >pos ;

