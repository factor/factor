
USING: kernel arrays sequences
       math math.points math.vectors math.geometry
       accessors ;

IN: math.geometry.rect

TUPLE: rect loc dim ;

GENERIC: rect-loc ( obj -- loc )
GENERIC: rect-dim ( obj -- dim )

: init-rect ( rect -- rect ) { 0 0 } clone >>loc { 0 0 } clone >>dim ;

: <rect> ( loc dim -- rect ) rect boa ;

: <zero-rect> ( -- rect ) rect new init-rect ;

M: array rect-loc ;

M: array rect-dim drop { 0 0 } ;

M: rect rect-loc loc>> ;

M: rect rect-dim dim>> ;

: rect-bounds ( rect -- loc dim ) dup rect-loc swap rect-dim ;

: rect-extent ( rect -- loc ext ) rect-bounds over v+ ;

: 2rect-extent ( rect rect -- loc1 loc2 ext1 ext2 )
    [ rect-extent ] bi@ swapd ;

: <extent-rect> ( loc ext -- rect ) over [v-] <rect> ;

: offset-rect ( rect loc -- newrect )
    over rect-loc v+ swap rect-dim <rect> ;

: (rect-intersect) ( rect rect -- array array )
    2rect-extent [ vmax ] [ vmin ] 2bi* ;

: rect-intersect ( rect1 rect2 -- newrect )
    (rect-intersect) <extent-rect> ;

: intersects? ( rect/point rect -- ? )
    (rect-intersect) [v-] { 0 0 } = ;

: (rect-union) ( rect rect -- array array )
    2rect-extent [ vmin ] [ vmax ] 2bi* ;

: rect-union ( rect1 rect2 -- newrect )
    (rect-union) <extent-rect> ;

M: rect width  ( rect -- width  ) dim>> first  ;
M: rect height ( rect -- height ) dim>> second ;

M: rect set-width!  ( rect width  -- rect ) over dim>> set-first  ;
M: rect set-height! ( rect height -- rect ) over dim>> set-second ;

M: rect set-x! ( rect x -- rect ) over loc>> set-first  ;
M: rect set-y! ( rect y -- rect ) over loc>> set-second ;

: rect-containing ( points -- rect )
    [ vleast ] [ vgreatest ] bi
    [ drop ] [ swap v- ] 2bi <rect> ;

! Accessing corners

: top-left     ( rect -- point ) loc>> ;
: top-right    ( rect -- point ) [ loc>> ] [ width  1 - ] bi v+x ;
: bottom-left  ( rect -- point ) [ loc>> ] [ height 1 - ] bi v+y ;
: bottom-right ( rect -- point ) [ loc>> ] [ dim>> ] bi v+ { 1 1 } v- ;

