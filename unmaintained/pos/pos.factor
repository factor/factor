
USING: kernel math math.functions math.vectors sequences self
accessors ;

IN: pos

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: pos val ;

C: <pos> pos

: pos> ( -- val ) self> val>> ;

: >pos ( val -- ) self> val<< ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: distance ( pos pos -- n ) val>> swap val>> v- [ sq ] map-sum sqrt ;

: move-by ( point -- ) pos> v+ >pos ;

