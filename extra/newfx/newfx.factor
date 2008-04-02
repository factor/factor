
USING: kernel sequences assocs qualified ;

QUALIFIED: sequences

IN: newfx

! Now, we can see a new world coming into view.
! A world in which there is the very real prospect of a new world order.
!
!    - George Herbert Walker Bush

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: nth-at ( seq i -- val ) swap nth ;
: nth-of ( i seq -- val )      nth ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: nth-is ( seq i val -- seq ) swap pick set-nth ;

: is-nth ( seq val i -- seq )      pick set-nth ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: at-key ( tbl key -- val ) swap at ;
: key-of ( key tbl -- val )      at ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: key-is ( tbl key val -- tbl ) swap pick set-at ;
: is-key ( tbl val key -- tbl )      pick set-at ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: push    ( seq obj -- seq ) over sequences:push ;
: push-on ( obj seq -- seq ) tuck sequences:push ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: member?    ( seq obj -- ? ) swap sequences:member? ;
: member-of? ( obj seq -- ? )      sequences:member? ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: delete-at-key ( tbl key -- tbl ) over delete-at ;
: delete-key-of ( key tbl -- tbl ) tuck delete-at ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

