! Copyright (C) 2009 Slava Pestov, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel math sequences sequences.private ;
IN: cursors

GENERIC: cursor-done? ( cursor -- ? )
GENERIC: cursor-get-unsafe ( cursor -- obj )
GENERIC: cursor-advance ( cursor -- )
GENERIC: cursor-valid? ( cursor -- ? )
GENERIC: cursor-write ( obj cursor -- )

ERROR: cursor-ended cursor ;

: cursor-get ( cursor -- obj )
    dup cursor-done?
    [ cursor-ended ] [ cursor-get-unsafe ] if ; inline

: find-done? ( cursor quot -- ? )
    over cursor-done?
    [ 2drop t ] [ [ cursor-get-unsafe ] dip call ] if ; inline

: cursor-until ( cursor quot -- )
    [ find-done? not ]
    [ drop cursor-advance ] bi-curry bi-curry while ; inline
 
: cursor-each ( cursor quot -- )
    [ f ] compose cursor-until ; inline

: cursor-find ( cursor quot -- obj ? )
    [ cursor-until ] [ drop ] 2bi
    dup cursor-done? [ drop f f ] [ cursor-get t ] if ; inline

: cursor-any? ( cursor quot -- ? )
    cursor-find nip ; inline

: cursor-all? ( cursor quot -- ? )
    [ not ] compose cursor-any? not ; inline

: cursor-map-quot ( quot to -- quot' )
    [ [ call ] dip cursor-write ] 2curry ; inline

: cursor-map ( from to quot -- )
   swap cursor-map-quot cursor-each ; inline

: cursor-write-if ( obj quot to -- )
    [ over [ call ] dip ] dip
    [ cursor-write ] 2curry when ; inline

: cursor-filter-quot ( quot to -- quot' )
    [ cursor-write-if ] 2curry ; inline

: cursor-filter ( from to quot -- )
    swap cursor-filter-quot cursor-each ; inline

TUPLE: from-sequence { seq sequence } { n integer } ;

: >from-sequence< ( from-sequence -- n seq )
    [ n>> ] [ seq>> ] bi ; inline

M: from-sequence cursor-done? ( cursor -- ? )
    >from-sequence< length >= ;

M: from-sequence cursor-valid?
    >from-sequence< bounds-check? not ;

M: from-sequence cursor-get-unsafe
    >from-sequence< nth-unsafe ;

M: from-sequence cursor-advance
    [ 1+ ] change-n drop ;

: >input ( seq -- cursor )
    0 from-sequence boa ; inline

: iterate ( seq quot iterator -- )
    [ >input ] 2dip call ; inline

: each ( seq quot -- ) [ cursor-each ] iterate ; inline
: find ( seq quot -- ? ) [ cursor-find ] iterate ; inline
: any? ( seq quot -- ? ) [ cursor-any? ] iterate ; inline
: all? ( seq quot -- ? ) [ cursor-all? ] iterate ; inline

TUPLE: to-sequence { seq sequence } { exemplar sequence } ;

M: to-sequence cursor-write
    seq>> push ;

: freeze ( cursor -- seq )
    [ seq>> ] [ exemplar>> ] bi like ; inline

: >output ( seq -- cursor )
    [ [ length ] keep new-resizable ] keep
    to-sequence boa ; inline

: transform ( seq quot transformer -- newseq )
    [ [ >input ] [ >output ] bi ] 2dip
    [ call ]
    [ 2drop freeze ] 3bi ; inline

: map ( seq quot -- ) [ cursor-map ] transform ; inline
: filter ( seq quot -- newseq ) [ cursor-filter ] transform ; inline
