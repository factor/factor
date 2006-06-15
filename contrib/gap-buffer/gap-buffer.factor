! gap buffer -- Alex Chapman (chapman.alex@gmail.com)
! largely influenced by Strandh and Villeneuve's Flexichain
! for a good introduction see:
! http://p-cos.net/lisp-ecoop/submissions/StrandhVilleneuveMoore.pdf
USING: kernel arrays sequences sequences-internals circular math generic ;
IN: gap-buffer

! gap-start     -- the first element of the gap
! gap-end       -- the first element after the gap
! expand-factor -- should be > 1
! min-size      -- < 5 is not sensible

TUPLE: gb
    gap-start
    gap-end
    expand-factor
    min-size ;

: required-space ( n gb -- n )
    tuck gb-expand-factor * ceiling >fixnum swap gb-min-size max ;

C: gb ( seq gb -- gb )
    5 over set-gb-min-size
    1.5 over set-gb-expand-factor
    [ >r length r> set-gb-gap-start ] 2keep
    [ swap length over required-space swap set-gb-gap-end ] 2keep
    [
	over length over required-space rot { } like resize-array <circular> swap set-delegate
    ] keep ;

M: gb like ( seq gb -- seq ) drop <gb> ;

: gap-length ( gb -- n ) [ gb-gap-end ] keep gb-gap-start - ;

: buffer-length ( gb -- n ) delegate length ;

M: gb length ( gb -- n ) [ buffer-length ] keep gap-length - ;

: position>index ( n gb -- n )
    2dup gb-gap-start >= [
	gap-length +
    ] [ drop ] if ;

: gb@ ( n gb -- n seq ) [ position>index ] keep delegate ;
    
M: gb nth ( n gb -- elt ) bounds-check gb@ nth-unsafe ;

M: gb nth-unsafe ( n gb -- elt ) gb@ nth-unsafe ;

M: gb set-nth ( elt n seq -- ) bounds-check gb@ set-nth-unsafe ;

M: gb set-nth-unsafe ( elt n seq -- ) gb@ set-nth-unsafe ;

! ------------- moving the gap -------------------------------

: (copy-element) ( to start seq -- ) tuck nth -rot set-nth ;

: copy-element ( dst start seq -- ) >r [ + ] keep r> (copy-element) ;

: copy-elements-back ( dst start seq n -- )
    dup 0 > [
	>r [ copy-element ] 3keep >r 1+ r> r> 1- copy-elements-back
    ] [ 3drop drop ] if ;

: copy-elements-forward ( dst start seq n -- )
    dup 0 > [
	>r [ copy-element ] 3keep >r 1- r> r> 1- copy-elements-forward
    ] [ 3drop drop ] if ;

: copy-elements ( dst start end seq -- )
    pick pick > [
	>r dupd - r> swap copy-elements-forward
    ] [
	>r over - r> swap copy-elements-back
    ] if ;

! the gap can be moved either forward or back. Moving the gap 'inside' means
! moving elements across the gap. Moving the gap 'around' means changing the
! start of the circular buffer to avoid moving as many elements.

! We decide which method (inside or around) to pick based on the number of
! elements that will need to be moved. We always try to move as few elements as
! possible.

: move-gap? ( i gb -- i gb ? ) 2dup gb-gap-end = not ;

: move-gap-forward? ( i gb -- i gb ? ) 2dup gb-gap-start >= ;

: move-gap-back-inside? ( i gb -- i gb ? )
    #! is it cheaper to move the gap inside than around?
    2dup [ gb-gap-start swap 2 * - ] keep [ buffer-length ] keep gb-gap-end - <= ;

: move-gap-forward-inside? ( i gb -- i gb ? )
    #! is it cheaper to move the gap inside than around?
    2dup [ gb-gap-end >r 2 * r> - ] keep [ gb-gap-start ] keep buffer-length + <= ;

: move-gap-forward-inside ( i gb -- )
    [ dup gap-length neg swap gb-gap-end rot ] keep delegate copy-elements ;

: move-gap-back-inside ( i gb -- )
    [ dup gap-length swap gb-gap-start 1- rot 1- ] keep delegate copy-elements ;

: move-gap-forward-around ( i gb -- )
    0 over move-gap-back-inside [
	dup buffer-length [
	    swap gap-length - neg swap
	] keep
    ] keep [
	delegate copy-elements
    ] keep dup gap-length swap delegate change-circular-start ;

: move-gap-back-around ( i gb -- )
    dup buffer-length over move-gap-forward-inside [
	length swap -1
    ] keep [
	delegate copy-elements
    ] keep dup length swap delegate change-circular-start ;

: move-gap-forward ( i gb -- )
    move-gap-forward-inside? [
	move-gap-forward-inside
    ] [
	move-gap-forward-around
    ] if ;

: move-gap-back ( i gb -- )
    move-gap-back-inside? [
	move-gap-back-inside
    ] [
	move-gap-back-around
    ] if ;

: (move-gap) ( i gb -- )
    move-gap? [
	move-gap-forward? [
	    move-gap-forward
	] [
	    move-gap-back
	] if
    ] [ 2drop ] if ;

: fix-gap ( n gb -- )
    2dup [ gap-length + ] keep set-gb-gap-end set-gb-gap-start ;

: move-gap ( n gb -- ) 2dup [ position>index ] keep (move-gap) fix-gap ;

! ------------ resizing -------------------------------------

: enough-room? ( n gb -- ? )
    #! is there enough room to add 'n' elements to gb?
    tuck length + swap buffer-length <= ;

: set-new-gap-end ( array gb -- )
    [ buffer-length swap length swap - ] keep
    [ gb-gap-end + ] keep set-gb-gap-end ;

: after-gap ( gb -- gb )
    dup gb-gap-end swap delegate tail ;

: before-gap ( gb -- gb )
    dup gb-gap-start swap head ;

: copy-after-gap ( array gb -- )
    #! copy everything after the gap in 'gb' into the end of 'array',
    #! and change 'gb's gap-end to reflect the gap-end in 'array'
    dup after-gap >r 2dup set-new-gap-end gb-gap-end swap r> copy-into ;

: copy-before-gap ( array gb -- )
    #! copy everything before the gap in 'gb' into the start of 'array'
    before-gap 0 -rot copy-into ; ! gap start doesn't change

: resize-buffer ( gb new-size -- )
    f <array> swap 2dup copy-before-gap 2dup copy-after-gap
    >r <circular> r> set-delegate ;

: decrease-buffer-size ( gb -- )
    #! the gap is too big, so resize to something sensible
    dup length over required-space resize-buffer ;

: increase-buffer-size ( n gb -- )
    #! increase the buffer to fit at least 'n' more elements
    tuck length + over required-space resize-buffer ;

: gb-too-big? ( gb -- ? )
    dup buffer-length over gb-min-size > [
	dup length over buffer-length rot gb-expand-factor sq / <
    ] [ drop f ] if ;

: maybe-decrease ( gb -- )
    dup gb-too-big? [
	decrease-buffer-size
    ] [ drop ] if ;

: ensure-room ( n gb -- )
    #! ensure that ther will be enough room for 'n' more elements
    2dup enough-room? [ 2drop ] [
	increase-buffer-size
    ] if ;

! ------- editing operations ---------------

G: insert* 2 standard-combination ;

: prepare-insert ( seq position gb -- seq gb )
    tuck move-gap over length over ensure-room ;

: insert-elements ( seq gb -- )
    dup gb-gap-start swap delegate rot copy-into ;

: increment-gap-start ( gb n -- )
    over gb-gap-start + swap set-gb-gap-start ;

M: sequence insert* ( seq position gb -- )
    prepare-insert [ insert-elements ] 2keep swap length increment-gap-start ;

M: object insert* ( elem position gb -- ) >r >r 1array r> r> insert* ;

: delete* ( position gb -- )
    tuck move-gap dup gb-gap-end 1+ over set-gb-gap-end maybe-decrease ;

! -------- stack/queue operations -----------

: push-start ( obj gb -- ) 0 swap insert* ;

: push-end ( obj gb -- ) [ length ] keep insert* ;

: pop-elem ( position gb -- elem ) [ nth ] 2keep delete* ;

: pop-start ( gb -- elem ) 0 swap pop-elem ;

: pop-end ( gb -- elem ) [ length 1- ] keep pop-elem ;

: rotate ( n gb -- )
    dup length 1 > [
	swap dup 0 > [
	    [ dup [ pop-end ] keep push-start ]
	] [
	    neg [ dup [ pop-start ] keep push-end ]
	] if times drop
    ] [ 2drop ] if ;

