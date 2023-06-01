! (c) 2009 Joe Groff, see BSD license
USING: assocs kernel math.rectangles combinators accessors
math.vectors vectors sequences math combinators.short-circuit arrays ;
IN: quadtrees

TUPLE: quadtree { bounds rect } point value ll lr ul ur leaf? ;

: <quadtree> ( bounds -- quadtree )
    quadtree new
        swap >>bounds
        t >>leaf? ;

: rect-ll ( rect -- point ) loc>> ;
: rect-lr ( rect -- point ) [ loc>> ] [ dim>> { 1 0 } v* ] bi v+ ;
: rect-ul ( rect -- point ) [ loc>> ] [ dim>> { 0 1 } v* ] bi v+ ;
: rect-ur ( rect -- point ) [ loc>> ] [ dim>>  ] bi v+ ;

: rect-center ( rect -- point ) [ loc>> ] [ dim>> 0.5 v*n ] bi v+ ; inline

: (quadrant) ( pt node -- quadrant )
    swap [ first 0.0 < ] [ second 0.0 < ] bi
    [ [ ll>> ] [ lr>> ] if ]
    [ [ ul>> ] [ ur>> ] if ] if ;

: quadrant ( pt node -- quadrant )
    [ bounds>> rect-center v- ] keep (quadrant) ;

: descend ( pt node -- pt subnode )
    [ drop ] [ quadrant ] 2bi ; inline

: each-quadrant ( node quot -- )
    {
        [ [ ll>> ] [ call ] bi* ]
        [ [ lr>> ] [ call ] bi* ]
        [ [ ul>> ] [ call ] bi* ]
        [ [ ur>> ] [ call ] bi* ]
    } 2cleave ; inline
: map-quadrant ( node quot: ( child-node -- x ) -- array )
    each-quadrant 4array ; inline

<PRIVATE

DEFER: (prune)
DEFER: insert
DEFER: erase
DEFER: at-point
DEFER: quadtree>alist
DEFER: quadtree-size
DEFER: node-insert
DEFER: in-rect*

: child-dim ( rect -- dim/2 ) dim>> 0.5 v*n ; inline
: ll-bounds ( rect -- rect' )
    [   loc>>                                  ] [ child-dim ] bi <rect> ;
: lr-bounds ( rect -- rect' )
    [ [ loc>> ] [ dim>> { 0.5 0.0 } v* ] bi v+ ] [ child-dim ] bi <rect> ;
: ul-bounds ( rect -- rect' )
    [ [ loc>> ] [ dim>> { 0.0 0.5 } v* ] bi v+ ] [ child-dim ] bi <rect> ;
: ur-bounds ( rect -- rect' )
    [ [ loc>> ] [ dim>> { 0.5 0.5 } v* ] bi v+ ] [ child-dim ] bi <rect> ;

: node>quadrants ( node -- quadrants )
    { [ ll>> ] [ lr>> ] [ ul>> ] [ ur>> ] } cleave 4array ;

: add-subnodes ( node -- node )
    dup bounds>> {
        [ ll-bounds <quadtree> >>ll ]
        [ lr-bounds <quadtree> >>lr ]
        [ ul-bounds <quadtree> >>ul ]
        [ ur-bounds <quadtree> >>ur ]
    } cleave
    f >>leaf? ;

: split-leaf ( value point leaf -- )
    add-subnodes
    [ value>> ] [ point>> ] [ ] tri
    [ node-insert ] [ node-insert ] bi ;

: leaf-replaceable? ( pt leaf -- ? ) point>> { [ nip not ] [ = ] } 2|| ;

: leaf-insert ( value point leaf -- )
    2dup leaf-replaceable?
    [ [ point<< ] [ value<< ] bi ]
    [ split-leaf ] if ;

: node-insert ( value point node -- )
    descend insert ;

: insert ( value point tree -- )
    dup leaf?>> [ leaf-insert ] [ node-insert ] if ;

:: leaf-at-point ( point leaf -- value/f ? )
    point leaf point>> =
    [ leaf value>> t ] [ f f ] if ;

: node-at-point ( point node -- value/f ? )
    descend at-point ;

: at-point ( point tree -- value/f ? )
    dup leaf?>> [ leaf-at-point ] [ node-at-point ] if ;

: (node-in-rect*) ( values rect node -- values )
    2dup bounds>> contains-rect? [ in-rect* ] [ 2drop ] if ;
: node-in-rect* ( values rect node -- values )
    [ (node-in-rect*) ] with each-quadrant ;

:: leaf-in-rect* ( values rect leaf -- values )
    { [ leaf point>> ] [ leaf point>> rect contains-point? ] } 0&&
    [ values leaf value>> suffix! ] [ values ] if ;

: in-rect* ( values rect tree -- values )
    dup leaf?>> [ leaf-in-rect* ] [ node-in-rect* ] if ;

:: leaf-erase ( point leaf -- )
    point leaf point>> = [ leaf f >>point f >>value drop ] when ;

: node-erase ( point node -- )
    descend erase ;

: erase ( point tree -- )
    dup leaf?>> [ leaf-erase ] [ node-erase ] if ;

: (?leaf) ( quadrant -- pair/f )
    dup point>> [ swap value>> 2array ] [ drop f ] if* ;
: ?leaf ( quadrants -- pair/f )
    [ (?leaf) ] map sift dup length {
        { 1 [ first ] }
        { 0 [ drop { f f } ] }
        [ 2drop f ]
    } case ;

: collapseable? ( node -- pair/f )
    node>quadrants { [ [ leaf?>> ] all? ] [ ?leaf ] } 1&& ;

: remove-subnodes ( node -- leaf ) f >>ll f >>lr f >>ul f >>ur t >>leaf? ;

: collapse ( node {point,value} -- )
    first2 [ >>point ] [ >>value ] bi* remove-subnodes drop ;

: node-prune ( node -- )
    [ [ (prune) ] each-quadrant ] [ ] [ collapseable? ] tri
    [ collapse ] [ drop ] if* ;

: (prune) ( tree -- )
    dup leaf?>> [ drop ] [ node-prune ] if ;

: leaf>alist ( leaf -- alist )
    dup point>> [ [ point>> ] [ value>> ] bi 2array 1array ] [ drop { } ] if ;

: node>alist ( node -- alist ) [ quadtree>alist ] map-quadrant concat ;

: quadtree>alist ( tree -- assoc )
    dup leaf?>> [ leaf>alist ] [ node>alist ] if ;

: leaf-size ( leaf -- count )
    point>> [ 1 ] [ 0 ] if ;
: node-size ( node -- count )
    0 swap [ quadtree-size + ] each-quadrant ;

: quadtree-size ( tree -- count )
    dup leaf?>> [ leaf-size ] [ node-size ] if ;

: leaf= ( a b -- ? ) [ [ point>> ] [ value>> ] bi 2array ] same? ;

: node= ( a b -- ? ) [ node>quadrants ] same? ;

: (tree=) ( a b -- ? ) dup leaf?>> [ leaf= ] [ node= ] if ;

: tree= ( a b -- ? )
    2dup [ leaf?>> ] same? [ (tree=) ] [ 2drop f ] if ;

PRIVATE>

: prune-quadtree ( tree -- tree ) [ (prune) ] keep ;

: in-rect ( tree rect -- values )
    [ 16 <vector> ] 2dip in-rect* ;

M: quadtree equal? ( a b -- ? )
    over quadtree? [ tree= ] [ 2drop f ] if ;

INSTANCE: quadtree assoc

M: quadtree at* ( key assoc -- value/f ? ) at-point ;
M: quadtree assoc-size ( assoc -- n ) quadtree-size ;
M: quadtree >alist ( assoc -- alist ) quadtree>alist ;
M: quadtree set-at ( value key assoc -- ) insert ;
M: quadtree delete-at ( key assoc -- ) erase ;
M: quadtree clear-assoc ( assoc -- )
    t >>leaf?
    f >>point
    f >>value
    drop ;

: swizzle ( sequence quot -- sequence' )
    dupd map
    [ zip ] [ rect-containing <quadtree> ] bi
    [ '[ first2 _ set-at ] each ] [ values ] bi ; inline
