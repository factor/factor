! Copyright (C) 2007 Alex Chapman All Rights Reserved.
! See http://factorcode.org/license.txt for BSD license.
!
! gap buffer -- largely influenced by Strandh and Villeneuve's Flexichain
! for a good introduction see:
! https://common-lisp.net/project/flexichain/download/StrandhVilleneuveMoore.pdf
USING: accessors arrays circular fry kernel math math.functions
math.order multiline sequences sequences.private ;
IN: gap-buffer

! gap-start     -- the first element of the gap
! gap-end       -- the first element after the gap
! expand-factor -- should be > 1 + +
! min-size      -- < 5 is not sensible

TUPLE: gb
    seq
    gap-start
    gap-end
    expand-factor
    min-size ;

: required-space ( n gb -- n )
    [ expand-factor>> * ceiling >fixnum ]
    [ min-size>> ] bi max ;

: <gb> ( seq -- gb )
    gb new
        5 >>min-size
        1.5 >>expand-factor
        swap
        [ length >>gap-start ] keep
        [ length over required-space >>gap-end ] keep
        over gap-end>> swap { } like resize-array <circular> >>seq ;

M: gb like ( seq gb -- seq ) drop <gb> ;

: gap-length ( gb -- n ) [ gap-end>> ] keep gap-start>> - ;

: buffer-length ( gb -- n ) seq>> length ;

M: gb length ( gb -- n ) [ buffer-length ] keep gap-length - ;

: valid-position? ( pos gb -- ? )
    ! one element past the end of the buffer is a valid position when we're inserting
    length -1 swap between? ;

: valid-index? ( i gb -- ? )
    buffer-length -1 swap between? ;

ERROR: position-out-of-bounds position gap-buffer ;

: position>index ( pos gb -- i )
    2dup valid-position? [
        2dup gap-start>> >= [
            gap-length +
        ] [ drop ] if
    ] [
        position-out-of-bounds
    ] if ;

TUPLE: index-out-of-bounds index gap-buffer ;
C: <index-out-of-bounds> index-out-of-bounds

: index>position ( i gb -- pos )
    2dup valid-index? [
        2dup gap-end>> >= [
            gap-length -
        ] [ drop ] if
    ] [
        <index-out-of-bounds> throw
    ] if ;

M: gb virtual@ ( n gb -- n seq ) [ position>index ] keep seq>> ;
    
M: gb nth ( n gb -- elt ) bounds-check virtual@ nth-unsafe ;

M: gb nth-unsafe ( n gb -- elt ) virtual@ nth-unsafe ;

M: gb set-nth ( elt n seq -- ) bounds-check virtual@ set-nth-unsafe ;

M: gb set-nth-unsafe ( elt n seq -- ) virtual@ set-nth-unsafe ;

M: gb virtual-exemplar seq>> ;

INSTANCE: gb virtual-sequence

! ------------- moving the gap -------------------------------

: (copy-element) ( to start seq -- ) tuck nth -rot set-nth ;

: copy-element ( dst start seq -- ) [ [ + ] keep ] dip (copy-element) ;

: copy-elements-back ( dst start seq n -- )
    dup 0 > [
        [ [ copy-element ] 3keep [ 1 + ] dip ] dip 1 - copy-elements-back
    ] [ 3drop drop ] if ;

: copy-elements-forward ( dst start seq n -- )
    dup 0 > [
        [ [ copy-element ] 3keep [ 1 - ] dip ] dip 1 - copy-elements-forward
    ] [ 3drop drop ] if ;

: copy-elements ( dst start end seq -- )
    pick pick > [
        [ dupd - ] dip swap copy-elements-forward
    ] [
        [ over - ] dip swap copy-elements-back
    ] if ;

! the gap can be moved either forward or back. Moving the gap 'inside' means
! moving elements across the gap. Moving the gap 'around' means changing the
! start of the circular buffer to avoid moving as many elements.

! We decide which method (inside or around) to pick based on the number of
! elements that will need to be moved. We always try to move as few elements as
! possible.

: move-gap? ( i gb -- i gb ? ) 2dup gap-end>> = not ;

: move-gap-forward? ( i gb -- i gb ? ) 2dup gap-start>> >= ;

: move-gap-back-inside? ( i gb -- i gb ? )
    ! is it cheaper to move the gap inside than around?
    2dup [ gap-start>> swap 2 * - ] keep [ buffer-length ] keep gap-end>> - <= ;

: move-gap-forward-inside? ( i gb -- i gb ? )
    ! is it cheaper to move the gap inside than around?
    2dup [ gap-end>> [ 2 * ] dip - ] keep [ gap-start>> ] keep buffer-length + <= ;

: move-gap-forward-inside ( i gb -- )
    [ dup gap-length neg swap gap-end>> rot ] keep seq>> copy-elements ;

: move-gap-back-inside ( i gb -- )
    [ dup gap-length swap gap-start>> 1 - rot 1 - ] keep seq>> copy-elements ;

: move-gap-forward-around ( i gb -- )
    0 over move-gap-back-inside [
        dup buffer-length [
            swap gap-length - neg swap
        ] keep
    ] keep [
        seq>> copy-elements
    ] keep dup gap-length swap seq>> change-circular-start ;

: move-gap-back-around ( i gb -- )
    dup buffer-length over move-gap-forward-inside [
        length swap -1
    ] keep [
        seq>> copy-elements
    ] keep dup length swap seq>> change-circular-start ;

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
    2dup [ gap-length + ] keep gap-end<< gap-start<< ;

! moving the gap to position 5 means that the element in position 5 will be immediately after the gap
GENERIC: move-gap ( n gb -- )

M: gb move-gap ( n gb -- ) 2dup [ position>index ] keep (move-gap) fix-gap ;

! ------------ resizing -------------------------------------

: enough-room? ( n gb -- ? )
    ! is there enough room to add 'n' elements to gb?
    tuck length + swap buffer-length <= ;

: set-new-gap-end ( array gb -- )
    [ buffer-length swap length swap - ] keep
    [ gap-end>> + ] keep gap-end<< ;

: after-gap ( gb -- gb )
    dup seq>> swap gap-end>> tail ;

: before-gap ( gb -- gb )
    dup gap-start>> head ;

: copy-after-gap ( array gb -- )
    ! copy everything after the gap in 'gb' into the end of 'array',
    ! and change 'gb's gap-end to reflect the gap-end in 'array'
    dup after-gap [ 2dup set-new-gap-end gap-end>> swap ] dip -rot copy ;

: copy-before-gap ( array gb -- )
    ! copy everything before the gap in 'gb' into the start of 'array'
    before-gap 0 rot copy ; ! gap start doesn't change

: resize-buffer ( gb new-size -- )
    f <array> swap 2dup copy-before-gap 2dup copy-after-gap
    [ <circular> ] dip seq<< ;

: decrease-buffer-size ( gb -- )
    ! the gap is too big, so resize to something sensible
    dup length over required-space resize-buffer ;

: increase-buffer-size ( n gb -- )
    ! increase the buffer to fit at least 'n' more elements
    tuck length + over required-space resize-buffer ;

: gb-too-big? ( gb -- ? )
    dup buffer-length over min-size>> > [
        dup length over buffer-length rot expand-factor>> sq / <
    ] [ drop f ] if ;

: ?decrease ( gb -- )
    dup gb-too-big? [
        decrease-buffer-size
    ] [ drop ] if ;

: ensure-room ( n gb -- )
    ! ensure that ther will be enough room for 'n' more elements
    2dup enough-room? [ 2drop ] [
        increase-buffer-size
    ] if ;

! ------- editing operations ---------------

GENERIC#: insert* 2 ( seq position gb -- )

: prepare-insert ( seq position gb -- seq gb )
    tuck move-gap over length over ensure-room ;

: insert-elements ( seq gb -- )
    dup gap-start>> swap seq>> copy ;

: increment-gap-start ( gb n -- )
    over gap-start>> + swap gap-start<< ;

! generic dispatch identifies numbers as sequences before numbers...
M: number insert* ( elem position gb -- ) [ 1array ] 2dip insert* ;
! : number-insert ( num position gb -- ) [ 1array ] 2dip insert* ;

M: sequence insert* ( seq position gb -- )
    prepare-insert [ insert-elements ] 2keep swap length increment-gap-start ;

: (delete*) ( gb -- )
    dup gap-end>> 1 + over gap-end<< ?decrease ;

GENERIC: delete* ( pos gb -- )

M: gb delete* ( position gb -- )
    tuck move-gap (delete*) ;

! -------- stack/queue operations -----------

: push-start ( obj gb -- ) 0 swap insert* ;

: push-end ( obj gb -- ) [ length ] keep insert* ;

: pop-elem ( position gb -- elem ) [ nth ] 2keep delete* ;

: pop-start ( gb -- elem ) 0 swap pop-elem ;

: pop-end ( gb -- elem ) [ length 1 - ] keep pop-elem ;

: rotate-right ( gb -- )
    dup [ pop-end ] keep push-start drop ;

: rotate-left ( gb -- )
    dup [ pop-start ] keep push-end drop ;

: rotate ( n gb -- )
    over 0 > [
        '[ _ rotate-right ] times
    ] [
        [ neg ] dip '[ _ rotate-left ] times
    ] if ;
