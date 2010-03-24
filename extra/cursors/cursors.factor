! (c)2010 Joe Groff bsd license
USING: accessors assocs combinators.short-circuit fry hashtables
kernel locals math math.functions sequences sequences.private ;
FROM: hashtables.private => tombstone? ;
IN: cursors

!
! basic cursor protocol
!

MIXIN: cursor

GENERIC: cursor-compatible? ( cursor cursor -- ? )
GENERIC: cursor-valid? ( cursor -- ? )
GENERIC: cursor= ( cursor cursor -- ? )
GENERIC: cursor<= ( cursor cursor -- ? )
GENERIC: cursor>= ( cursor cursor -- ? )
GENERIC: cursor-distance-hint ( cursor cursor -- n )

M: cursor cursor<= cursor= ; inline
M: cursor cursor>= cursor= ; inline
M: cursor cursor-distance-hint 2drop 0 ; inline

!
! cursor iteration
!

MIXIN: forward-cursor
INSTANCE: forward-cursor cursor

GENERIC: inc-cursor ( cursor -- cursor' )

MIXIN: bidirectional-cursor
INSTANCE: bidirectional-cursor forward-cursor

GENERIC: dec-cursor ( cursor -- cursor' )

MIXIN: random-access-cursor
INSTANCE: random-access-cursor bidirectional-cursor

GENERIC# cursor+ 1 ( cursor n -- cursor' )
GENERIC# cursor- 1 ( cursor n -- cursor' )
GENERIC: cursor-distance ( cursor cursor -- n )
GENERIC: cursor<  ( cursor cursor -- ? )
GENERIC: cursor>  ( cursor cursor -- ? )

M: random-access-cursor inc-cursor  1 cursor+ ; inline
M: random-access-cursor dec-cursor -1 cursor+ ; inline
M: random-access-cursor cursor- neg cursor+ ; inline
M: random-access-cursor cursor<= { [ cursor= ] [ cursor< ] } 2|| ; inline
M: random-access-cursor cursor>= { [ cursor= ] [ cursor> ] } 2|| ; inline
M: random-access-cursor cursor-distance-hint cursor-distance ; inline

!
! input cursors
!

ERROR: invalid-cursor cursor ;

MIXIN: input-cursor

GENERIC: cursor-value ( cursor -- value )
<PRIVATE
GENERIC: cursor-value-unsafe ( cursor -- value )
PRIVATE>
M: input-cursor cursor-value-unsafe cursor-value ; inline
M: input-cursor cursor-value
    dup cursor-valid? [ cursor-value-unsafe ] [ invalid-cursor ] if ; inline

!
! output cursors
!

MIXIN: output-cursor

GENERIC: set-cursor-value ( value cursor -- )
<PRIVATE
GENERIC: set-cursor-value-unsafe ( value cursor -- )
PRIVATE>
M: output-cursor set-cursor-value-unsafe set-cursor-value ; inline
M: output-cursor set-cursor-value
    dup cursor-valid? [ set-cursor-value-unsafe ] [ invalid-cursor ] if ; inline

!
! basic iterator
!

: -each ( ... begin end quot: ( ... cursor -- ... ) -- ... )
    [ '[ dup _ cursor>= ] ]
    [ '[ _ keep inc-cursor ] ] bi* until drop ; inline

!
! numeric cursors
!

TUPLE: numeric-cursor
    { value read-only } ;

M: numeric-cursor cursor-valid? drop t ; inline

M: numeric-cursor cursor=  [ value>> ] bi@ =  ; inline

M: numeric-cursor cursor<= [ value>> ] bi@ <= ; inline
M: numeric-cursor cursor<  [ value>> ] bi@ <  ; inline
M: numeric-cursor cursor>  [ value>> ] bi@ >  ; inline
M: numeric-cursor cursor>= [ value>> ] bi@ >= ; inline

INSTANCE: numeric-cursor input-cursor

M: numeric-cursor cursor-value value>> ; inline

!
! linear cursor
!

TUPLE: linear-cursor < numeric-cursor
    { delta read-only } ;
C: <linear-cursor> linear-cursor

INSTANCE: linear-cursor random-access-cursor

M: linear-cursor cursor-compatible?
    [ linear-cursor? ] both? ; inline

M: linear-cursor inc-cursor
    [ value>> ] [ delta>> ] bi [ + ] keep <linear-cursor> ; inline
M: linear-cursor dec-cursor
    [ value>> ] [ delta>> ] bi [ - ] keep <linear-cursor> ; inline
M: linear-cursor cursor+
    [ [ value>> ] [ delta>> ] bi ] dip [ * + ] keep <linear-cursor> ; inline
M: linear-cursor cursor-
    [ [ value>> ] [ delta>> ] bi ] dip [ * - ] keep <linear-cursor> ; inline

GENERIC: up/i ( distance delta -- distance' )
M: integer up/i [ 1 - + ] keep /i ; inline
M: real up/i / ceiling >integer ; inline

M: linear-cursor cursor-distance
    [ [ value>> ] bi@ - ] [ nip delta>> ] 2bi up/i ; inline

!
! quadratic cursor
!

TUPLE: quadratic-cursor < numeric-cursor
    { delta read-only }
    { delta2 read-only } ;

C: <quadratic-cursor> quadratic-cursor

INSTANCE: quadratic-cursor bidirectional-cursor

M: quadratic-cursor cursor-compatible?
    [ linear-cursor? ] both? ; inline

M: quadratic-cursor inc-cursor
    [ value>> ] [ delta>> [ + ] keep ] [ delta2>> [ + ] keep ] tri <quadratic-cursor> ; inline

M: quadratic-cursor dec-cursor
    [ value>> ] [ delta>> ] [ delta2>> ] tri [ - [ - ] keep ] keep <quadratic-cursor> ; inline

!
! collections
!

MIXIN: collection

GENERIC: begin-cursor ( collection -- cursor )
GENERIC: end-cursor ( collection -- cursor )

: all- ( collection quot -- begin end quot )
    [ [ begin-cursor ] [ end-cursor ] bi ] dip ; inline

!
! containers
!

MIXIN: container
INSTANCE: container collection

: -container- ( quot -- quot' )
    '[ cursor-value-unsafe @ ] ; inline

: container- ( container quot -- begin end quot' )
    all- -container- ; inline

: each ( ... container quot: ( ... x -- ... ) -- ... ) container- -each ; inline

!
! sequence cursor
!

TUPLE: sequence-cursor
    { seq read-only }
    { n fixnum read-only } ;
C: <sequence-cursor> sequence-cursor
    
INSTANCE: sequence container

M: sequence begin-cursor 0 <sequence-cursor> ; inline
M: sequence end-cursor dup length <sequence-cursor> ; inline

INSTANCE: sequence-cursor random-access-cursor

M: sequence-cursor cursor-compatible?
    {
        [ [ sequence-cursor? ] both? ]
        [ [ seq>> ] bi@ eq? ]
    } 2&& ; inline

M: sequence-cursor cursor-valid?
    [ n>> ] [ seq>> ] bi bounds-check? ; inline

M: sequence-cursor cursor=  [ n>> ] bi@ =  ; inline
M: sequence-cursor cursor<= [ n>> ] bi@ <= ; inline
M: sequence-cursor cursor>= [ n>> ] bi@ >= ; inline
M: sequence-cursor cursor<  [ n>> ] bi@ <  ; inline
M: sequence-cursor cursor>  [ n>> ] bi@ >  ; inline
M: sequence-cursor inc-cursor [ seq>> ] [ n>> ] bi 1 + <sequence-cursor> ; inline
M: sequence-cursor dec-cursor [ seq>> ] [ n>> ] bi 1 - <sequence-cursor> ; inline
M: sequence-cursor cursor+ [ [ seq>> ] [ n>> ] bi ] dip + <sequence-cursor> ; inline
M: sequence-cursor cursor- [ [ seq>> ] [ n>> ] bi ] dip - <sequence-cursor> ; inline
M: sequence-cursor cursor-distance ( cursor cursor -- n )
    [ n>> ] bi@ - ; inline

INSTANCE: sequence-cursor input-cursor

M: sequence-cursor cursor-value-unsafe [ n>> ] [ seq>> ] bi nth-unsafe ; inline
M: sequence-cursor cursor-value [ n>> ] [ seq>> ] bi nth ; inline

INSTANCE: sequence-cursor output-cursor

M: sequence-cursor set-cursor-value-unsafe [ n>> ] [ seq>> ] bi set-nth-unsafe ; inline
M: sequence-cursor set-cursor-value [ n>> ] [ seq>> ] bi set-nth ; inline

!
! pipe cursor
!

TUPLE: pipe-cursor
    { from read-only }
    { to read-only } ;
C: <pipe-cursor> pipe-cursor

INSTANCE: pipe-cursor forward-cursor

M: pipe-cursor cursor-compatible? [ from>> ] bi@ cursor-compatible? ; inline
M: pipe-cursor cursor-valid? [ from>> ] [ to>> ] bi [ cursor-valid? ] both? ; inline
M: pipe-cursor cursor= [ from>> ] bi@ cursor= ; inline
M: pipe-cursor inc-cursor [ from>> inc-cursor ] [ to>> inc-cursor ] bi <pipe-cursor> ; inline

INSTANCE: pipe-cursor output-cursor

M: pipe-cursor set-cursor-value-unsafe to>> set-cursor-value-unsafe ; inline
M: pipe-cursor set-cursor-value        to>> set-cursor-value        ; inline

: -pipe- ( begin end quot to -- begin' end' quot' )
    swap [ '[ _ <pipe-cursor> ] bi@ ] dip '[ from>> @ ] ; inline

!
! pusher cursor
!

TUPLE: pusher-cursor
    { growable read-only } ;
C: <pusher-cursor> pusher-cursor

INSTANCE: pusher-cursor forward-cursor

! XXX define a protocol for stream cursors that don't actually move
M: pusher-cursor cursor-compatible? 2drop f ; inline
M: pusher-cursor cursor-valid? drop t ; inline
M: pusher-cursor cursor= 2drop f ; inline
M: pusher-cursor inc-cursor ; inline

INSTANCE: pusher-cursor output-cursor

M: pusher-cursor set-cursor-value growable>> push ; inline

!
! Create cursors into new sequences
!

: new-growable-cursor ( begin end exemplar -- cursor result )
    [ swap cursor-distance-hint ] dip new-resizable [ <pusher-cursor> ] keep ; inline

GENERIC# new-sequence-cursor 1 ( begin end exemplar -- cursor result )

M: random-access-cursor new-sequence-cursor
    [ swap cursor-distance ] dip new-sequence [ begin-cursor ] keep ; inline
M: forward-cursor new-sequence-cursor
    new-growable-cursor ; inline

: -into-sequence- ( begin end quot exemplar -- begin' end' quot' result )
    swap [ [ 2dup ] dip new-sequence-cursor ] dip swap [ swap -pipe- ] dip ; inline

: -into-growable- ( begin end quot exemplar -- begin' end' quot' result )
    swap [ [ 2dup ] dip new-growable-cursor ] dip swap [ swap -pipe- ] dip ; inline

!
! map
!

: -map- ( quot -- quot' )
    '[ _ keep set-cursor-value-unsafe ] ; inline

: -map ( ... begin end quot: ( ... cursor -- ... value ) -- ... )
    -map- -each ; inline

! XXX generalize exemplar
: -map-as ( ... begin end quot: ( ... cursor -- ... value ) exemplar -- ... newseq )
    [ -into-sequence- [ -map ] dip ] keep like ; inline

: map! ( ... container quot: ( ... x -- ... newx ) -- ... container )
    [ container- -map ] keep ; inline
: map-as ( ... container quot: ( ... x -- ... newx ) exemplar -- ... newseq )
    [ container- ] dip -map-as ; inline
: map ( ... container quot: ( ... x -- ... newx ) -- ... newcontainer )
    over map-as ; inline

!
! assoc cursors
!

MIXIN: assoc-cursor

GENERIC: cursor-key-value ( cursor -- key value )

: -assoc- ( quot -- quot' )
    '[ cursor-key-value @ ] ; inline

: assoc- ( assoc quot -- begin end quot' )
    all- -assoc- ; inline

: assoc-each ( ... assoc quot: ( ... k v -- ... ) -- ... )
    assoc- -each ; inline
: assoc>map ( ... assoc quot: ( ... k v -- ... newx ) exemplar -- ... newcontainer )
    [ assoc- ] dip -map-as ; inline

INSTANCE: input-cursor assoc-cursor

M: input-cursor cursor-key-value
    cursor-value first2 ; inline

!
! hashtable cursor
!

TUPLE: hashtable-cursor
    { hashtable hashtable read-only }
    { n fixnum read-only } ;
<PRIVATE
C: <hashtable-cursor> hashtable-cursor
PRIVATE>

INSTANCE: hashtable-cursor forward-cursor

M: hashtable-cursor cursor-compatible?
    {
        [ [ hashtable-cursor? ] both? ]
        [ [ hashtable>> ] bi@ eq? ]
    } 2&& ; inline

M: hashtable-cursor cursor-valid? ( cursor -- ? )
    [ n>> ] [ hashtable>> array>> ] bi bounds-check? ; inline

M: hashtable-cursor cursor= ( cursor cursor -- ? )
    [ n>> ] bi@ = ; inline
M: hashtable-cursor cursor-distance-hint ( cursor cursor -- n )
    nip hashtable>> assoc-size ; inline

<PRIVATE
: (inc-hashtable-cursor) ( array n -- n' )
    [ 2dup swap { [ length < ] [ nth-unsafe tombstone? ] } 2&& ] [ 2 + ] while nip ; inline
PRIVATE>

M: hashtable-cursor inc-cursor ( cursor -- cursor' )
    [ hashtable>> dup array>> ] [ n>> 2 + ] bi
    (inc-hashtable-cursor) <hashtable-cursor> ; inline

INSTANCE: hashtable-cursor assoc-cursor
    
M: hashtable-cursor cursor-key-value
    [ n>> ] [ hashtable>> array>> ] bi
    [ nth-unsafe ] [ [ 1 + ] dip nth-unsafe ] 2bi ; inline

INSTANCE: hashtable collection

M: hashtable begin-cursor
    dup array>> 0 (inc-hashtable-cursor) <hashtable-cursor> ; inline
M: hashtable end-cursor
    dup array>> length <hashtable-cursor> ; inline
