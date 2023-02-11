! Copyright (C) 2008, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel arrays sequences math math.vectors accessors
parser ;
IN: math.rectangles

TUPLE: rect { loc initial: { 0 0 } } { dim initial: { 0 0 } } ;

: <rect> ( loc dim -- rect ) rect boa ; inline

SYNTAX: RECT: scan-object scan-object <rect> suffix! ;

: <zero-rect> ( -- rect ) rect new ; inline

: point>rect ( loc -- rect ) { 0 0 } <rect> ; inline

: rect-bounds ( rect -- loc dim ) [ loc>> ] [ dim>> ] bi ;

: rect-extent ( rect -- loc ext ) rect-bounds over v+ ;

: rect-center ( rect -- center ) rect-bounds 2 v/n v+ ;

: with-rect-extents ( ..a+b rect1 rect2 loc-quot: ( ..a loc1 loc2 -- ..c ) ext-quot: ( ..b ext1 ext2 -- ..d ) -- ..c+d )
    [ [ rect-extent ] bi@ ] 2dip bi-curry* bi* ; inline

: <extent-rect> ( loc ext -- rect ) over [v-] <rect> ;

: offset-rect ( rect loc -- newrect )
    over loc>> v+ swap dim>> <rect> ;

: (rect-intersect) ( rect rect -- array array )
    [ vmax ] [ vmin ] with-rect-extents ;

: rect-intersect ( rect1 rect2 -- newrect )
    (rect-intersect) <extent-rect> ;

GENERIC: contains-rect? ( rect1 rect2 -- ? )

M: rect contains-rect?
    (rect-intersect) [v-] { 0 0 } = ;

GENERIC: contains-point? ( point rect -- ? )

M: rect contains-point?
    [ point>rect ] dip contains-rect? ;

: (rect-union) ( rect rect -- array array )
    [ vmin ] [ vmax ] with-rect-extents ;

: rect-union ( rect1 rect2 -- newrect )
    (rect-union) <extent-rect> ;

: rect-containing ( points -- rect )
    [ vsupremum ] [ vinfimum ] bi
    [ nip ] [ v- ] 2bi <rect> ;

: rect-min ( rect dim -- rect' )
    [ rect-bounds ] dip vmin <rect> ;

: set-rect-bounds ( rect1 rect -- )
    [ [ loc>> ] dip loc<< ]
    [ [ dim>> ] dip dim<< ]
    2bi ; inline

USE: vocabs.loader

{ "math.rectangles" "prettyprint" } "math.rectangles.prettyprint" require-when
