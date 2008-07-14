
USING: kernel arrays math.vectors ;

IN: math.geometry.rect

TUPLE: rect { loc initial: { 0 0 } } { dim initial: { 0 0 } } ;

: <zero-rect> ( -- rect ) rect new ;

C: <rect> rect

M: array rect-loc ;

M: array rect-dim drop { 0 0 } ;

: rect-bounds ( rect -- loc dim ) dup rect-loc swap rect-dim ;

: rect-extent ( rect -- loc ext ) rect-bounds over v+ ;

: 2rect-extent ( rect rect -- loc1 loc2 ext1 ext2 )
    [ rect-extent ] bi@ swapd ;

: <extent-rect> ( loc ext -- rect ) over [v-] <rect> ;

: offset-rect ( rect loc -- newrect )
    over rect-loc v+ swap rect-dim <rect> ;

: (rect-intersect) ( rect rect -- array array )
    2rect-extent vmin >r vmax r> ;

: rect-intersect ( rect1 rect2 -- newrect )
    (rect-intersect) <extent-rect> ;

: intersects? ( rect/point rect -- ? )
    (rect-intersect) [v-] { 0 0 } = ;

: (rect-union) ( rect rect -- array array )
    2rect-extent vmax >r vmin r> ;

: rect-union ( rect1 rect2 -- newrect )
    (rect-union) <extent-rect> ;

