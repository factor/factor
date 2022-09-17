USING: accessors arrays assocs colors combinators
combinators.short-circuit combinators.smart kernel locals math
math.functions math.order math.ranges math.vectors opengl.gl
sequences ui.gadgets ui.gadgets.packs ui.pens ui.pens.caching
skov.basis.ui.pens.gradient system ;
IN: skov.basis.ui.pens.gradient-rounded

TUPLE: gradient-shape < caching-pen  colors foreground shape last-vertices last-colors ;
TUPLE: gradient-squircle < gradient-shape ;
TUPLE: gradient-arrow < gradient-shape ;
TUPLE: gradient-pointy < gradient-shape ;
TUPLE: gradient-dynamic-shape < gradient-shape  selected? ;

: <gradient-squircle> ( colors foreground -- gradient )
    gradient-squircle new swap >>foreground swap >>colors ;

: <gradient-arrow> ( colors foreground -- gradient )
    gradient-arrow new swap >>foreground swap >>colors ;

: <gradient-pointy> ( colors foreground -- gradient )
    gradient-pointy new swap >>foreground swap >>colors ;

: <gradient-dynamic-shape> ( colors foreground selected? -- gradient )
    gradient-dynamic-shape new swap >>selected? swap >>foreground swap >>colors ;

<PRIVATE

CONSTANT: tau 6.283185307179586
CONSTANT: points 100

: squircle-point ( theta -- xy )
    [ cos ] [ sin ] bi [ [ abs sqrt ] [ sgn ] bi * 0.5 * 0.5 + ] bi@ 2array ;

:: tan-point ( y slope -- xy )
    y tau * 4 / tan 300 / 0.5 min y slope / + y 2array ;

:: squircle ( -- seq )
    1/4 tau * 3/4 tau * 1/2 tau * points / <range> [ squircle-point ] map ;

:: arrow ( -- seq )
    { { -0.25 1 } { 0 0.5 } { -0.25 0 } } ;

:: wide-narrow ( slope -- seq )
    0.0 1.0 1 points / <range> [ slope tan-point ] map reverse ;

: narrow-wide ( slope -- seq )
    wide-narrow unzip [ reverse ] dip zip ;

:: wide-narrow-wide ( slope -- seq )
    slope wide-narrow unzip drop slope narrow-wide unzip [ [ min ] 2map ] dip zip ;

:: narrow-wide-narrow ( slope -- seq )
    slope wide-narrow unzip drop slope narrow-wide unzip [ [ max ] 2map ] dip zip ;

:: vertices ( dim left-shape right-shape symmetric? -- seq )
    dim first2 :> ( x y )
    left-shape right-shape [ call( -- seq ) [ y v*n ] map ] bi@
    reverse symmetric? [ [ first2 [ neg ] dip 2array ] map ] unless
    [ first2 swap x swap - swap 2array ] map append
    x 2 / y 2 / 2array prefix dup second suffix ;

:: interp-color ( x colors -- seq )
    colors [ >rgba-components 4array ] map first2 zip [ first2 dupd - x * - ] map ;

:: vertices-colors ( dim seq colors -- seq )
    seq [ second dim second / colors interp-color ] map ;

: draw-triangle-fan ( vertices colors -- )
    GL_TRIANGLE_FAN glBegin
    [ first3 glColor3f first2 glVertex2f ] 2each
    glEnd ;

:: gradient-start ( edge center -- s )
    center first2 :> ( xc yc )
    edge first2 :> ( xe ye )
    8 xe xc - sq ye yc - sq + sqrt / :> alpha
    xe xe xc - alpha * -
    ye ye yc - alpha * - 8 max 16 min 2array ;

: draw-triangle-fan-selected ( vertices -- )
    unclip dupd [ gradient-start ] curry map
    GL_TRIANGLE_STRIP glBegin
    [ 1.0 1.0 1.0 0.0 glColor4f first2 glVertex2f
      1.0 1.0 1.0 0.6 glColor4f first2 glVertex2f ] 2each
    glEnd ;

: left ( gadget -- dim )  screen-loc first ;
: right ( gadget -- dim )  [ screen-loc first ] [ dim>> first ] bi + ;

: default-value ( side -- x )
    \ left = 10000 0 ? ;

: compare ( x y side -- ? )
    \ left = [ 3 - < ] [ 3 + > ] if ;

:: above ( gadget side -- dim )
    gadget parent>> gadget-child children>> [ empty? not ]
    [ side \ left = [ first ] [ last ] if children>> second side execute( x -- x ) ]
    [ side default-value ] smart-if* ;

:: below ( gadget side -- dim )
    gadget parent>> parent>>
    [ dup parent>> children>> { [ length 1 > nip ] [ second = not ] } 2&& ]
    [ parent>> children>> second side execute( x -- x ) ]
    [ side default-value ] smart-if* ;

:: above-wider? ( gadget side -- ? )
    gadget [ side above ] [ side execute( x -- x ) ] bi side compare ;

:: below-wider? ( gadget side -- ? )
    gadget [ side below ] [ side execute( x -- x ) ] bi side compare ;

:: find-half-shape ( gadget side -- shape )  {
        { [ gadget left 10 < ] [ [ squircle ] ] }
        { [ gadget side above-wider? gadget side below-wider? and ] [ [ 6 wide-narrow-wide ] ] }
        { [ gadget side above-wider? gadget side below-wider? not and ] [ [ 6 wide-narrow ] ] }
        { [ gadget side above-wider? not gadget side below-wider? and ] [ [ 6 narrow-wide ] ] }
        { [ gadget side above-wider? not gadget side below-wider? not and ] [ [ 6 narrow-wide-narrow ] ] }
    } cond ;

: find-shape ( gadget -- left-shape right-shape )
    [ \ left find-half-shape ] [ \ right find-half-shape ] bi ;

:: (recompute-pen) ( gadget gradient left-shape right-shape symmetric? -- )
    gadget dim>> dup left-shape right-shape symmetric? vertices dup gradient last-vertices<<
    gradient colors>> vertices-colors gradient last-colors<< ;

M: gradient-squircle recompute-pen ( gadget gradient -- )
    [ squircle ] dup t (recompute-pen) ;

M: gradient-arrow recompute-pen ( gadget gradient -- )
    [ arrow ] dup f (recompute-pen) ;

M: gradient-pointy recompute-pen ( gadget gradient -- )
    [ 1.5 narrow-wide-narrow ] dup t (recompute-pen) ;

M:: gradient-dynamic-shape recompute-pen ( gadget gradient -- )
    gadget gradient gadget find-shape t (recompute-pen) ;

PRIVATE>

M: gradient-shape draw-interior
    [ compute-pen ]
    [ last-vertices>> ]
    [ last-colors>> draw-triangle-fan ] tri ;

M: gradient-shape pen-background
     2drop transparent ;

M: gradient-shape pen-foreground
    nip foreground>> ;

M: gradient-dynamic-shape draw-interior
    [ call-next-method ]
    [ selected?>> ]
    [ last-vertices>> ] tri
    [ draw-triangle-fan-selected ] curry when ;
