
USING: accessors arrays combinators combinators.short-circuit
fry kernel locals math math.intervals math.vectors multi-methods
sequences ;
FROM: multi-methods => GENERIC: ;
IN: flatland

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! Two dimensional world protocol

GENERIC: x ( obj -- x )
GENERIC: y ( obj -- y )

GENERIC: (x!) ( x obj -- )
GENERIC: (y!) ( y obj -- )

: x! ( obj x -- obj ) over (x!) ;
: y! ( obj y -- obj ) over (y!) ;

GENERIC: width  ( obj -- width  )
GENERIC: height ( obj -- height )

GENERIC: (width!)  ( width  obj -- )
GENERIC: (height!) ( height obj -- )

: width!  ( obj width  -- obj ) over (width!) ;
: height! ( obj height -- obj ) over (width!) ;

! Predicates on relative placement

GENERIC: to-the-left-of?  ( obj obj -- ? )
GENERIC: to-the-right-of? ( obj obj -- ? )

GENERIC: below? ( obj obj -- ? )
GENERIC: above? ( obj obj -- ? )

GENERIC: in-between-horizontally? ( obj obj -- ? )

GENERIC: horizontal-interval ( obj -- interval )

GENERIC: move-to ( obj obj -- )

GENERIC: move-by ( obj delta -- )

GENERIC: move-left-by  ( obj obj -- )
GENERIC: move-right-by ( obj obj -- )

GENERIC: left   ( obj -- left   )
GENERIC: right  ( obj -- right  )
GENERIC: bottom ( obj -- bottom )
GENERIC: top    ( obj -- top    )

GENERIC: distance ( a b -- c )

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! Some of the above methods work on two element sequences.
! A two element sequence may represent a point in space or describe
! width and height.

METHOD: x { sequence } first  ;
METHOD: y { sequence } second ;

METHOD: (x!) { number sequence } set-first  ;
METHOD: (y!) { number sequence } set-second ;

METHOD: width  { sequence } first  ;
METHOD: height { sequence } second ;

: changed-x ( seq quot -- ) over [ [ x ] dip call ] dip (x!) ; inline
: changed-y ( seq quot -- ) over [ [ y ] dip call ] dip (y!) ; inline

METHOD: move-to { sequence sequence }         [ x x! ] [ y y! ] bi drop ;
METHOD: move-by { sequence sequence } dupd v+ [ x x! ] [ y y! ] bi drop ;

METHOD: move-left-by  { sequence number } '[ _ - ] changed-x ;
METHOD: move-right-by { sequence number } '[ _ + ] changed-x ;

! METHOD: move-left-by  { sequence number } neg 0 2array move-by ;
! METHOD: move-right-by { sequence number }     0 2array move-by ;

! METHOD:: move-left-by  { SEQ:sequence X:number -- )
!   SEQ { X 0 } { -1 0 } v* move-by ;

METHOD: distance { sequence sequence } v- norm ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! A class for objects with a position

TUPLE: <pos> pos ;

METHOD: x { <pos> } pos>> first  ;
METHOD: y { <pos> } pos>> second ;

METHOD: (x!) { number <pos> } pos>> set-first  ;
METHOD: (y!) { number <pos> } pos>> set-second ;

METHOD: to-the-left-of?  { <pos> number } [ x ] dip < ;
METHOD: to-the-right-of? { <pos> number } [ x ] dip > ;

METHOD: move-left-by  { <pos> number } [ pos>> ] dip move-left-by  ;
METHOD: move-right-by { <pos> number } [ pos>> ] dip move-right-by ;

METHOD: above? { <pos> number } [ y ] dip > ;
METHOD: below? { <pos> number } [ y ] dip < ;

METHOD: move-by { <pos> sequence } '[ _ v+ ] change-pos drop ;

METHOD: distance { <pos> <pos> } [ pos>> ] bi@ distance ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! A class for objects with velocity. It inherits from <pos>. Hey, if
! it's moving it has a position right? Unless it's some alternate universe...

TUPLE: <vel> < <pos> vel ;

: moving-up?   ( obj -- ? ) vel>> y 0 > ;
: moving-down? ( obj -- ? ) vel>> y 0 < ;

: step-size ( vel time -- dist ) [ vel>> ] dip v*n      ;
: move-for  ( vel time --      ) dupd step-size move-by ;

: reverse-horizontal-velocity ( vel -- ) vel>> [ x neg ] [ ] bi (x!) ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! The 'pos' slot indicates the lower left hand corner of the
! rectangle. The 'dim' is holds the width and height.

TUPLE: <rectangle> < <pos> dim ;

METHOD: width  { <rectangle> } dim>> first  ;
METHOD: height { <rectangle> } dim>> second ;

METHOD: left   { <rectangle> }    x             ;
METHOD: right  { <rectangle> } [ x ] [ width ] bi + ;
METHOD: bottom { <rectangle> }    y             ;
METHOD: top    { <rectangle> } [ y ] [ height ] bi + ;

: bottom-left ( rectangle -- pos ) pos>> ;

: center-x ( rectangle -- x ) [ left   ] [ width  2 / ] bi + ;
: center-y ( rectangle -- y ) [ bottom ] [ height 2 / ] bi + ;

: center ( rectangle -- seq ) [ center-x ] [ center-y ] bi 2array ;

METHOD: to-the-left-of?  { <pos> <rectangle> } [ x ] [ left  ] bi* < ;
METHOD: to-the-right-of? { <pos> <rectangle> } [ x ] [ right ] bi* > ;

METHOD: below? { <pos> <rectangle> } [ y ] [ bottom ] bi* < ;
METHOD: above? { <pos> <rectangle> } [ y ] [ top    ] bi* > ;

METHOD: horizontal-interval { <rectangle> }
  [ left ] [ right ] bi [a,b] ;

METHOD: in-between-horizontally? { <pos> <rectangle> }
  [ x ] [ horizontal-interval ] bi* interval-contains? ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: <extent> left right bottom top ;

METHOD: left   { <extent> } left>>   ;
METHOD: right  { <extent> } right>>  ;
METHOD: bottom { <extent> } bottom>> ;
METHOD: top    { <extent> } top>>    ;

METHOD: width  { <extent> } [ right>> ] [ left>>   ] bi - ;
METHOD: height { <extent> } [ top>>   ] [ bottom>> ] bi - ;

! METHOD: to-extent ( <rectangle> -- <extent> )
!   { [ left>> ] [ right>> ] [ bottom>> ] [ top>> ] } cleave <extent> boa ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

METHOD: to-the-left-of?  { sequence <rectangle> } [ x ] [ left ] bi* < ;
METHOD: to-the-right-of? { sequence <rectangle> } [ x ] [ right ] bi* > ;

METHOD: below? { sequence <rectangle> } [ y ] [ bottom ] bi* < ;
METHOD: above? { sequence <rectangle> } [ y ] [ top    ] bi* > ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! Some support for the' 'rect' class from math.geometry.rect'

! METHOD: width  ( rect -- width  ) dim>> first  ;
! METHOD: height ( rect -- height ) dim>> second ;

! METHOD: left  ( rect -- left  ) loc>> x
! METHOD: right ( rect -- right ) [ loc>> x ] [ width ] bi + ;

! METHOD: to-the-left-of?  ( sequence rect -- ? ) [ x ] [ loc>> x ] bi* < ;
! METHOD: to-the-right-of? ( sequence rect -- ? ) [ x ] [ loc>> x ] bi* > ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

:: wrap ( POINT RECT -- POINT )
  {
      { [ POINT RECT to-the-left-of?  ] [ RECT right ] }
      { [ POINT RECT to-the-right-of? ] [ RECT left  ] }
      { [ t                           ] [ POINT x    ] }
  }
  cond

  {
      { [ POINT RECT below? ] [ RECT top    ] }
      { [ POINT RECT above? ] [ RECT bottom ] }
      { [ t                 ] [ POINT y     ] }
  }
  cond

  2array ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

GENERIC: within? ( a b -- ? )

METHOD: within? { <pos> <rectangle> }
  {
    [ left   to-the-right-of? ]
    [ right  to-the-left-of?  ]
    [ bottom above?           ]
    [ top    below?           ]
  }
  2&& ;
