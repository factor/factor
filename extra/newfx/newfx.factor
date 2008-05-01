
USING: kernel sequences assocs qualified circular ;

USING: math multi-methods ;

QUALIFIED: sequences
QUALIFIED: assocs
QUALIFIED: circular

IN: newfx

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Now, we can see a new world coming into view.
! A world in which there is the very real prospect of a new world order.
!
!    - George Herbert Walker Bush
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

GENERIC: at ( col key -- val )
GENERIC: of ( key col -- val )

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

GENERIC: grab ( col key -- col val )

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

GENERIC: is ( col key val -- col )
GENERIC: as ( col val key -- col )

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

GENERIC: is-of ( key val col -- col )
GENERIC: as-of ( val key col -- col )

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

GENERIC: mutate-at ( col key val -- )
GENERIC: mutate-as ( col val key -- )

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

GENERIC: at-mutate ( key val col -- )
GENERIC: as-mutate ( val key col -- )

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! sequence
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

METHOD: at { sequence number  } swap nth ;
METHOD: of { number  sequence }      nth ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

METHOD: grab { sequence number } dupd swap nth ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

METHOD: is { sequence number object  } swap pick set-nth ;
METHOD: as { sequence object  number }      pick set-nth ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

METHOD: is-of { number object  sequence } dup >r swapd set-nth r> ;
METHOD: as-of { object  number sequence } dup >r       set-nth r> ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

METHOD: mutate-at { sequence number object  } swap rot set-nth ;
METHOD: mutate-as { sequence object  number }      rot set-nth ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

METHOD: at-mutate { number object  sequence } swapd set-nth ;
METHOD: as-mutate { object  number sequence }       set-nth ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!



! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! assoc
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

METHOD: at { assoc object } swap assocs:at ;
METHOD: of { object assoc }      assocs:at ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

METHOD: grab { assoc object } dupd swap assocs:at ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

METHOD: is { assoc object object } swap pick set-at ;
METHOD: as { assoc object object }      pick set-at ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

METHOD: is-of { object object assoc } dup >r swapd set-at r> ;
METHOD: as-of { object object assoc } dup >r       set-at r> ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

METHOD: mutate-at { assoc object object } swap rot set-at ;
METHOD: mutate-as { assoc object object }      rot set-at ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

METHOD: at-mutate { object object assoc } swapd set-at ;
METHOD: as-mutate { object object assoc }       set-at ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: push      ( seq obj -- seq ) over sequences:push ;
: push-on   ( obj seq -- seq ) tuck sequences:push ;
: pushed    ( seq obj --     ) swap sequences:push ;
: pushed-on ( obj seq --     )      sequences:push ;

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

: filter-of ( quot seq -- seq ) swap filter ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: map-over ( quot seq -- seq ) swap map ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: push-circular ( seq elt -- seq ) over circular:push-circular ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: prefix-on ( elt seq -- seq ) swap prefix ;
: suffix-on ( elt seq -- seq ) swap suffix ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: 1st 0 at ;
: 2nd 1 at ;
: 3rd 2 at ;
: 4th 3 at ;
: 5th 4 at ;
: 6th 5 at ;
: 7th 6 at ;
: 8th 7 at ;
: 9th 8 at ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! A note about the 'mutate' qualifier. Other words also technically mutate
! their primary object. However, the 'mutate' qualifier is supposed to
! indicate that this is the main objective of the word, as a side effect.