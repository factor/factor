! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences sequences.private accessors math
math.order combinators hints arrays ;
IN: binary-search

<PRIVATE

: midpoint ( seq -- elt )
    [ midpoint@ ] keep nth-unsafe ; inline

: decide ( quot seq -- quot seq <=> )
    [ midpoint swap call ] 2keep rot ; inline

: finish ( quot slice -- i elt )
    [ [ from>> ] [ midpoint@ ] bi + ] [ seq>> ] bi
    [ drop ] [ dup ] [ ] tri* nth ; inline

DEFER: (search)

: keep-searching ( seq quot -- slice )
    [ dup midpoint@ ] dip call collapse-slice slice boa (search) ; inline

: (search) ( quot: ( elt -- <=> ) seq -- i elt )
    dup length 1 <= [
        finish
    ] [
        decide {
            { +eq+ [ finish ] }
            { +lt+ [ [ (head) ] keep-searching ] }
            { +gt+ [ [ (tail) ] keep-searching ] }
        } case
    ] if ; inline recursive

PRIVATE>

: search ( seq quot -- i elt )
    over empty? [ 2drop f f ] [ swap <flat-slice> (search) ] if ;
    inline

: natural-search ( obj seq -- i elt )
    [ <=> ] with search ;

HINTS: natural-search array ;

: sorted-index ( obj seq -- i )
    natural-search drop ;

: sorted-member? ( obj seq -- ? )
    dupd natural-search nip = ;

: sorted-member-eq? ( obj seq -- ? )
    dupd natural-search nip eq? ;
