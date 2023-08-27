! Copyright (C) 2010 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators.short-circuit fry
generalizations hash-sets hashtables kernel macros math
math.functions math.order sequences sets ;
FROM: sequences.private => nth-unsafe set-nth-unsafe ;
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

GENERIC#: cursor+ 1 ( cursor n -- cursor' )
GENERIC#: cursor- 1 ( cursor n -- cursor' )
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

GENERIC: cursor-key-value ( cursor -- key value )
<PRIVATE
GENERIC: cursor-key-value-unsafe ( cursor -- key value )
PRIVATE>
M: input-cursor cursor-key-value-unsafe cursor-key-value ; inline
M: input-cursor cursor-key-value
    dup cursor-valid?
    [ cursor-key-value-unsafe ]
    [ invalid-cursor ] if ; inline

: cursor-key ( cursor -- key ) cursor-key-value drop ;
: cursor-value ( cursor -- key ) cursor-key-value nip ;

: cursor-key-unsafe ( cursor -- key ) cursor-key-value-unsafe drop ;
: cursor-value-unsafe ( cursor -- key ) cursor-key-value-unsafe nip ;

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
    dup cursor-valid?
    [ set-cursor-value-unsafe ]
    [ invalid-cursor ] if ; inline

!
! stream cursors
!

MIXIN: stream-cursor
INSTANCE: stream-cursor forward-cursor

M: stream-cursor cursor-compatible? 2drop f ; inline
M: stream-cursor cursor-valid? drop t ; inline
M: stream-cursor cursor= 2drop f ; inline

MIXIN: infinite-stream-cursor
INSTANCE: infinite-stream-cursor stream-cursor

M: infinite-stream-cursor inc-cursor ; inline

MIXIN: finite-stream-cursor
INSTANCE: finite-stream-cursor stream-cursor

SINGLETON: end-of-stream

GENERIC: cursor-stream-ended? ( cursor -- ? )

M: finite-stream-cursor inc-cursor
    dup cursor-stream-ended? [ drop end-of-stream ] when ; inline

INSTANCE: end-of-stream finite-stream-cursor

M: end-of-stream cursor-compatible? drop finite-stream-cursor? ; inline
M: end-of-stream cursor-valid? drop f ; inline
M: end-of-stream cursor= eq? ; inline
M: end-of-stream inc-cursor ; inline
M: end-of-stream cursor-stream-ended? drop t ; inline

!
! basic iterators
!

: -each ( ... begin end quot: ( ... cursor -- ... ) -- ... )
    [ '[ dup _ cursor>= ] ]
    [ '[ _ keep inc-cursor ] ] bi* until drop ; inline

: -find ( ... begin end quot: ( ... cursor -- ... ? ) -- ... cursor )
    '[ dup _ cursor>= [ t ] [ dup @ ] if ] [ inc-cursor ] until ; inline

: -in- ( quot -- quot' )
    '[ cursor-value-unsafe @ ] ; inline

: -out- ( quot -- quot' )
    '[ _ keep set-cursor-value-unsafe ] ; inline

: -out ( ... begin end quot: ( ... cursor -- ... value ) -- ... )
    -out- -each ; inline

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

M: numeric-cursor cursor-key-value value>> dup ; inline

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

: all ( collection -- begin end )
    [ begin-cursor ] [ end-cursor ] bi ; inline

: all- ( collection quot -- begin end quot )
    [ all ] dip ; inline

!
! containers
!

MIXIN: container
INSTANCE: container collection

: in- ( container quot -- begin end quot' )
    all- -in- ; inline

: each ( ... container quot: ( ... x -- ... ) -- ... ) in- -each ; inline

INSTANCE: finite-stream-cursor container

M: finite-stream-cursor begin-cursor ; inline
M: finite-stream-cursor end-cursor drop end-of-stream ; inline

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

M: sequence-cursor cursor-key-value-unsafe [ n>> dup ] [ seq>> ] bi nth-unsafe ; inline
M: sequence-cursor cursor-key-value [ n>> dup ] [ seq>> ] bi nth ; inline

INSTANCE: sequence-cursor output-cursor

M: sequence-cursor set-cursor-value-unsafe [ n>> ] [ seq>> ] bi set-nth-unsafe ; inline
M: sequence-cursor set-cursor-value [ n>> ] [ seq>> ] bi set-nth ; inline

!
! hash-set cursor
!

TUPLE: hash-set-cursor
    { hash-set hash-set read-only }
    { n fixnum read-only } ;
<PRIVATE
C: <hash-set-cursor> hash-set-cursor
PRIVATE>

INSTANCE: hash-set-cursor forward-cursor

M: hash-set-cursor cursor-compatible?
    {
        [ [ hash-set-cursor? ] both? ]
        [ [ hash-set>> ] bi@ eq? ]
    } 2&& ; inline

M: hash-set-cursor cursor-valid? ( cursor -- ? )
    [ n>> ] [ hash-set>> array>> ] bi bounds-check? ; inline

M: hash-set-cursor cursor= ( cursor cursor -- ? )
    [ n>> ] bi@ = ; inline
M: hash-set-cursor cursor-distance-hint ( cursor cursor -- n )
    nip hash-set>> cardinality ; inline

<PRIVATE
: (inc-hash-set-cursor) ( array n -- n' )
    [ 2dup swap { [ length < ] [ nth-unsafe tombstone? ] } 2&& ] [ 1 + ] while nip ; inline
PRIVATE>

M: hash-set-cursor inc-cursor ( cursor -- cursor' )
    [ hash-set>> dup array>> ] [ n>> 1 + ] bi
    (inc-hash-set-cursor) <hash-set-cursor> ; inline

INSTANCE: hash-set-cursor input-cursor

M: hash-set-cursor cursor-key-value-unsafe
    [ n>> dup ] [ hash-set>> array>> ] bi nth-unsafe ; inline

INSTANCE: hash-set container

M: hash-set begin-cursor
    dup array>> 0 (inc-hash-set-cursor) <hash-set-cursor> ; inline
M: hash-set end-cursor
    dup array>> length <hash-set-cursor> ; inline

!
! map cursor
!

TUPLE: map-cursor
    { from read-only }
    { to read-only } ;
C: <map-cursor> map-cursor

INSTANCE: map-cursor forward-cursor

M: map-cursor cursor-compatible? [ from>> ] bi@ cursor-compatible? ; inline
M: map-cursor cursor-valid? [ from>> ] [ to>> ] bi [ cursor-valid? ] both? ; inline
M: map-cursor cursor= [ from>> ] bi@ cursor= ; inline
M: map-cursor inc-cursor [ from>> inc-cursor ] [ to>> inc-cursor ] bi <map-cursor> ; inline

INSTANCE: map-cursor output-cursor

M: map-cursor set-cursor-value-unsafe to>> set-cursor-value-unsafe ; inline
M: map-cursor set-cursor-value        to>> set-cursor-value        ; inline

: -map- ( begin end quot to -- begin' end' quot' )
    swap [ '[ _ <map-cursor> ] bi@ ] dip '[ from>> @ ] -out- ; inline

: -map ( begin end quot to -- begin' end' quot' )
    -map- -each ; inline

!
! pusher cursor
!

TUPLE: pusher-cursor
    { growable read-only } ;
C: <pusher-cursor> pusher-cursor

INSTANCE: pusher-cursor infinite-stream-cursor
INSTANCE: pusher-cursor output-cursor

M: pusher-cursor set-cursor-value growable>> push ; inline

!
! Create cursors into new sequences
!

: new-growable-cursor ( begin end exemplar -- cursor result )
    [ swap cursor-distance-hint ] dip new-resizable [ <pusher-cursor> ] keep ; inline

GENERIC#: new-sequence-cursor 1 ( begin end exemplar -- cursor result )

M: random-access-cursor new-sequence-cursor
    [ swap cursor-distance ] dip new-sequence [ begin-cursor ] keep ; inline
M: forward-cursor new-sequence-cursor
    new-growable-cursor ; inline

: -into-sequence- ( begin end quot exemplar -- begin' end' quot' cursor result )
    [ 2over ] dip new-sequence-cursor ; inline

: -into-growable- ( begin end quot exemplar -- begin' end' quot' cursor result )
    [ 2over ] dip new-growable-cursor ; inline

!
! map combinators
!

! XXX generalize exemplar
: -map-as ( ... begin end quot: ( ... cursor -- ... value ) exemplar -- ... newseq )
    [ -into-sequence- [ -map ] dip ] keep like ; inline

: map! ( ... container quot: ( ... x -- ... newx ) -- ... container )
    [ in- -out ] keep ; inline
: map-as ( ... container quot: ( ... x -- ... newx ) exemplar -- ... newseq )
    [ in- ] dip -map-as ; inline
: map ( ... container quot: ( ... x -- ... newx ) -- ... newcontainer )
    over map-as ; inline

!
! assoc combinators
!

: -assoc- ( quot -- quot' )
    '[ cursor-key-value @ ] ; inline

: assoc- ( assoc quot -- begin end quot' )
    all- -assoc- ; inline

: assoc-each ( ... assoc quot: ( ... k v -- ... ) -- ... )
    assoc- -each ; inline
: assoc>map ( ... assoc quot: ( ... k v -- ... newx ) exemplar -- ... newcontainer )
    [ assoc- ] dip -map-as ; inline

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

INSTANCE: hashtable-cursor input-cursor

M: hashtable-cursor cursor-key-value-unsafe
    [ n>> ] [ hashtable>> array>> ] bi
    [ nth-unsafe ] [ [ 1 + ] dip nth-unsafe ] 2bi ; inline

INSTANCE: hashtable container

M: hashtable begin-cursor
    dup array>> 0 (inc-hashtable-cursor) <hashtable-cursor> ; inline
M: hashtable end-cursor
    dup array>> length <hashtable-cursor> ; inline

!
! zip cursor
!

TUPLE: zip-cursor
    { keys   read-only }
    { values read-only } ;
C: <zip-cursor> zip-cursor

INSTANCE: zip-cursor forward-cursor

M: zip-cursor cursor-compatible? ( cursor cursor -- ? )
    {
        [ [ zip-cursor? ] both? ]
        [ [ keys>> ] bi@ cursor-compatible? ]
        [ [ values>> ] bi@ cursor-compatible? ]
    } 2&& ; inline

M: zip-cursor cursor-valid? ( cursor -- ? )
    [ keys>> ] [ values>> ] bi [ cursor-valid? ] both? ; inline
M: zip-cursor cursor= ( cursor cursor -- ? )
    {
        [ [ keys>> ] bi@ cursor= ]
        [ [ values>> ] bi@ cursor= ]
    } 2|| ; inline

M: zip-cursor cursor-distance-hint ( cursor cursor -- n )
    [ [ keys>> ] bi@ cursor-distance-hint ]
    [ [ values>> ] bi@ cursor-distance-hint ] 2bi min ; inline

M: zip-cursor inc-cursor ( cursor -- cursor' )
    [ keys>> inc-cursor ] [ values>> inc-cursor ] bi <zip-cursor> ; inline

INSTANCE: zip-cursor input-cursor

M: zip-cursor cursor-key-value
    [ keys>> cursor-value-unsafe ] [ values>> cursor-value-unsafe ] bi ; inline

: zip-cursors ( a-begin a-end b-begin b-end -- begin end )
    [ <zip-cursor> ] bi-curry@ bi* ; inline

: 2all ( a b -- begin end )
    [ all ] bi@ zip-cursors ; inline

: 2all- ( a b quot -- begin end quot )
    [ 2all ] dip ; inline

ALIAS: -2in- -assoc-

: 2in- ( a b quot -- begin end quot' )
    2all- -2in- ; inline

: 2each ( ... a b quot: ( ... x y -- ... ) -- ... )
    2in- -each ; inline

: 2map-as ( ... a b quot: ( ... x y -- ... z ) exemplar -- ... c )
    [ 2in- ] dip -map-as ; inline

: 2map ( ... a b quot: ( ... x y -- ... z ) -- ... c )
    pick 2map-as ; inline

!
! generalized zips
!

: -unzip- ( quot -- quot' )
    '[ [ keys>> cursor-value-unsafe ] [ values>> ] bi @ ] ; inline

MACRO: nzip-cursors ( n -- quot ) 1 - [ zip-cursors ] n*quot ;

: nall ( seqs... n -- begin end ) [ [ all ] swap napply ] [ nzip-cursors ] bi ; inline

: nall- ( seqs... quot n -- begin end quot ) swap [ nall ] dip ; inline

MACRO: -nin- ( n -- quot )
    1 - [ -unzip- ] n*quot [ -in- ] prepend ;

: nin- ( seqs... quot n -- begin end quot ) [ nall- ] [ -nin- ] bi ; inline

: neach ( seqs... quot n -- ) nin- -each ; inline
: nmap-as ( seqs... quot exemplar n -- newseq )
    swap [ nin- ] dip -map-as ; inline
: nmap ( seqs... quot n -- newseq )
    dup [ npick ] curry [ dip swap ] curry dip nmap-as ; inline

!
! utilities
!

: -with- ( invariant begin end quot -- begin end quot' )
    rotd '[ [ _ ] dip @ ] ; inline

: -2with- ( invariant invariant begin end quot -- begin end quot' )
    -with- -with- ; inline

MACRO: -nwith- ( n -- quot )
    [ -with- ] n*quot ;
