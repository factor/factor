
USING: kernel sequences assocs circular sets fry ;

USING: math multi-methods ;

QUALIFIED: sequences
QUALIFIED: assocs
QUALIFIED: circular
QUALIFIED: sets

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

METHOD: is-of { number object  sequence } dup [ swapd set-nth ] dip ;
METHOD: as-of { object  number sequence } dup [       set-nth ] dip ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

METHOD: mutate-at { sequence number object  } swap rot set-nth ;
METHOD: mutate-as { sequence object  number }      rot set-nth ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

METHOD: at-mutate { number object  sequence } swapd set-nth ;
METHOD: as-mutate { object  number sequence }       set-nth ;

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

METHOD: is-of { object object assoc } dup [ swapd set-at ] dip ;
METHOD: as-of { object object assoc } dup [       set-at ] dip ;

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

: filter-of ( quot seq -- seq ) swap filter ; inline

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: map-over ( quot seq -- seq ) swap map ; inline

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: push-circular ( seq elt -- seq ) over circular:push-circular ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: prefix-on ( elt seq -- seq ) swap prefix ;
: suffix-on ( elt seq -- seq ) swap suffix ;

: suffix!      ( seq elt -- seq ) over sequences:push ;
: suffix-on!   ( elt seq -- seq ) tuck sequences:push ;
: suffixed!    ( seq elt --     ) swap sequences:push ;
: suffixed-on! ( elt seq --     )      sequences:push ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: subseq ( seq from to -- subseq ) rot sequences:subseq ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: key ( table val -- key ) swap assocs:value-at ;

: key-of ( val table -- key ) assocs:value-at ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: index    ( seq obj -- i ) swap sequences:index ;
: index-of ( obj seq -- i )      sequences:index ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: 1st ( seq -- obj ) 0 swap nth ;
: 2nd ( seq -- obj ) 1 swap nth ;
: 3rd ( seq -- obj ) 2 swap nth ;
: 4th ( seq -- obj ) 3 swap nth ;
: 5th ( seq -- obj ) 4 swap nth ;
: 6th ( seq -- obj ) 5 swap nth ;
: 7th ( seq -- obj ) 6 swap nth ;
: 8th ( seq -- obj ) 7 swap nth ;
: 9th ( seq -- obj ) 8 swap nth ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! A note about the 'mutate' qualifier. Other words also technically mutate
! their primary object. However, the 'mutate' qualifier is supposed to
! indicate that this is the main objective of the word, as a side effect.

: adjoin      ( seq elt -- seq ) over sets:adjoin ;
: adjoin-on   ( elt seq -- seq ) tuck sets:adjoin ;
: adjoined    ( set elt --     ) swap sets:adjoin ;
: adjoined-on ( elt set --     )      sets:adjoin ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: start ( seq subseq -- i ) swap sequences:start ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: pluck         ( seq i   -- seq ) cut-slice rest-slice append ;
: pluck-from    ( i   seq -- seq ) swap pluck ;
: pluck!        ( seq i   -- seq ) over delete-nth ;
: pluck-from!   ( i   seq -- seq ) tuck delete-nth ;
: plucked!      ( seq i   --     ) swap delete-nth ;
: plucked-from! ( i   seq --     )      delete-nth ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: snip          ( seq a b -- seq ) [ over ] dip [ head ] [ tail ] 2bi* append ;
: snip-this     ( a b seq -- seq ) -rot snip ;
: snip!         ( seq a b -- seq )      pick delete-slice ;
: snip-this!    ( a b seq -- seq ) -rot pick delete-slice ;
: snipped!      ( seq a b --     )       rot delete-slice ;
: snipped-from! ( a b seq --     )           delete-slice ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: invert-index ( seq i -- seq i ) [ dup length 1 - ] dip - ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: append!      ( a b -- ab )      over sequences:push-all ;
: append-to!   ( b a -- ab ) swap over sequences:push-all ;
: appended!    ( a b --    ) swap      sequences:push-all ;
: appended-to! ( b a --    )           sequences:push-all ;

: prepend!   ( a b -- ba  ) over append 0 pick copy ;
: prepended! ( a b --     ) over append 0 rot  copy ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: insert ( seq i obj -- seq ) [ cut ] dip prefix append ;

: splice ( seq i seq -- seq ) [ cut ] dip prepend append ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: purge ( seq quot -- seq ) [ not ] compose filter ; inline

: purge! ( seq quot -- seq )
  dupd '[ swap @ [ pluck! ] [ drop ] if ] each-index ; inline
