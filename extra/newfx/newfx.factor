
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

: nth-is ( seq   i val -- seq ) swap pick set-nth ;
: is-nth ( seq val   i -- seq )      pick set-nth ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: nth-is-of (   i val seq -- seq ) dup >r swapd set-nth r> ;
: is-nth-of ( val   i seq -- seq ) dup >r       set-nth r> ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: mutate-nth    ( seq i val -- ) swap rot set-nth ;
: mutate-nth-at ( seq val i -- )      rot set-nth ;

: mutate-nth-of    (   i val seq -- ) swapd set-nth ;
: mutate-nth-at-of ( val   i seq -- )       set-nth ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: at-key ( tbl key -- val ) swap at ;
: key-of ( key tbl -- val )      at ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: key-is ( tbl key val -- tbl ) swap pick set-at ;
: is-key ( tbl val key -- tbl )      pick set-at ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: mutate-key    ( tbl key val -- ) swap rot set-at ;
: mutate-at-key ( tbl val key -- )      rot set-at ;

: mutate-key-of    ( key val tbl -- ) swapd set-at ;
: mutate-at-key-of ( val key tbl -- )       set-at ;

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

: delete      ( seq elt -- seq ) over sequences:delete ;
: delete-from ( elt seq -- seq ) tuck sequences:delete ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: deleted      ( seq elt -- ) swap sequences:delete ;
: deleted-from ( elt seq -- )      sequences:delete ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: remove      ( seq obj -- seq ) swap sequences:remove ;
: remove-from ( obj seq -- seq )      sequences:remove ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: subset-of ( quot seq -- seq ) swap subset ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: map-over ( quot seq -- seq ) swap map ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! A note about the 'mutate' qualifier. Other words also technically mutate
! their primary object. However, the 'mutate' qualifier is supposed to
! indicate that this is the main objective of the word, as a side effect.