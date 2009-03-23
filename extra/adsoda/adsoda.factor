! Copyright (C) 2008 Jeff Bigot
! See http://factorcode.org/license.txt for BSD license.
USING: accessors
arrays 
assocs
combinators
kernel 
fry
math 
math.constants
math.functions
math.libm
math.order
math.vectors 
math.matrices 
math.parser
namespaces
prettyprint
sequences
sequences.deep
sets
slots
sorting
tools.time
vars
continuations
words
opengl
opengl.gl
colors
adsoda.solution2
adsoda.combinators
opengl.demo-support
values
tools.walker
;

IN: adsoda

DEFER: combinations
VAR: pv


! -------------------------------------------------------------
! global values
VALUE: remove-hidden-solids?
VALUE: VERY-SMALL-NUM
VALUE: ZERO-VALUE
VALUE: MAX-FACE-PER-CORNER

t to: remove-hidden-solids?
0.0000001 to: VERY-SMALL-NUM
0.0000001 to: ZERO-VALUE
4 to: MAX-FACE-PER-CORNER
! -------------------------------------------------------------
! sequence complement

: with-pv ( i quot -- ) [ swap >pv call ] with-scope  ; inline

: dimension ( array -- x )      length 1- ; inline 
: last ( seq -- x )           [ dimension ] [ nth ] bi ; inline
: change-last ( seq quot -- ) 
    [ [ dimension ] keep ] dip change-nth  ; inline

! -------------------------------------------------------------
! light
! -------------------------------------------------------------

TUPLE: light name { direction array } color ;
: <light> ( -- tuple ) light new ;

! -------------------------------------------------------------
! halfspace manipulation
! -------------------------------------------------------------

: constant+ ( v x -- w )  '[ [ _ + ] change-last ] keep ;
: translate ( u v -- w )   dupd     v* sum     constant+ ; 

: transform ( u matrix -- w )
    [ swap m.v ] 2keep ! compute new normal vector    
    [
        [ [ abs ZERO-VALUE > ] find ] keep 
        ! find a point on the frontier
        ! be sure it's not null vector
        last ! get constant
        swap /f neg swap ! intercept value
    ] dip  
    flip 
    nth
    [ * ] with map ! apply intercep value
    over v*
    sum  neg
    suffix ! add value as constant at the end of equation
;

: position-point ( halfspace v -- x ) 
    -1 suffix v* sum  ; inline
: point-inside-halfspace? ( halfspace v -- ? )       
    position-point VERY-SMALL-NUM  > ; 
: point-inside-or-on-halfspace? ( halfspace v -- ? ) 
    position-point VERY-SMALL-NUM neg > ;
: project-vector (  seq -- seq )     
    pv> [ head ] [ 1+  tail ] 2bi append ; 
: get-intersection ( matrice -- seq )     
    [ 1 tail* ] map     flip first ;

: islenght=? ( seq n -- seq n ? ) 2dup [ length ] [ = ] bi*  ;

: compare-nleft-to-identity-matrix ( seq n -- ? ) 
    [ [ head ] curry map ] keep  identity-matrix m- 
    flatten
    [ abs ZERO-VALUE < ] all?
;

: valid-solution? ( matrice n -- ? )
    islenght=?
    [ compare-nleft-to-identity-matrix ]  
    [ 2drop f ] if ; inline

: intersect-hyperplanes ( matrice -- seq )
    [ solution dup ] [ first dimension ] bi
    valid-solution?     [ get-intersection ] [ drop f ] if ;

! -------------------------------------------------------------
! faces
! -------------------------------------------------------------

TUPLE: face { halfspace array } 
    touching-corners adjacent-faces ;
: <face> ( v -- tuple )       face new swap >>halfspace ;
: flip-face ( face -- face ) [ vneg ] change-halfspace ;
: erase-face-touching-corners ( face -- face ) 
    f >>touching-corners ;
: erase-face-adjacent-faces ( face -- face )   
    f >>adjacent-faces ;
: faces-intersection ( faces -- v )  
    [ halfspace>> ] map intersect-hyperplanes ;
: face-translate ( face v -- face ) 
    [ translate ] curry change-halfspace ; inline
: face-transform ( face m -- face )
    [ transform ] curry change-halfspace ; inline
: face-orientation ( face -- x ) pv> swap halfspace>> nth sgn ;
: backface? ( face -- face ? )      dup face-orientation 0 <= ;
: pv-factor ( face -- f face )     
    halfspace>> [ pv> swap nth [ * ] curry ] keep ; inline
: suffix-touching-corner ( face corner -- face ) 
    [ suffix ] curry   change-touching-corners ; inline
: real-face? ( face -- ? )
    [ touching-corners>> length ] 
    [ halfspace>> dimension ] bi >= ;

: (add-to-adjacent-faces) ( face face -- face )
    over adjacent-faces>> 2dup member?
    [ 2drop ] [ swap suffix >>adjacent-faces ] if ;

: add-to-adjacent-faces ( face face -- face )
    2dup =   [ drop ] [ (add-to-adjacent-faces) ] if ;

: update-adjacent-faces ( faces corner -- )
   '[ [ _ suffix-touching-corner drop ] each ] keep 
    2 among [ 
        [ first ] keep second  
        [ add-to-adjacent-faces drop ] 2keep 
        swap add-to-adjacent-faces drop  
    ] each ; inline

: face-project-dim ( face -- x )  halfspace>> length 2 -  ;

: apply-light ( color light normal -- u )
    over direction>>  v. 
    neg dup 0 > 
    [ 
        [ color>> swap ] dip 
        [ * ] curry map v+ 
        [ 1 min ] map 
    ] 
    [ 2drop ] 
    if
;

: enlight-projection ( array face -- color )
    ! array = lights + ambient color
    [ [ third ] [ second ] [ first ] tri ]
    [ halfspace>> project-vector normalize ] bi*
    [ apply-light ] curry each
    v*
;

: (intersection-into-face) ( face-init face-adja quot -- face )
    [
    [  [ pv-factor ] bi@ 
        roll 
        [ map ] 2bi@
        v-
    ] 2keep
    [ touching-corners>> ] bi@
    [ swap  [ = ] curry find  nip f = ] curry find nip
    ] dip  over
     [
        call
        dupd
        point-inside-halfspace? [ vneg ] unless 
        <face> 
     ] [ 3drop f ] if 
    ; inline

: intersection-into-face ( face-init face-adja -- face )
    [ [ project-vector ] bi@ ]     (intersection-into-face) ;

: intersection-into-silhouette-face ( face-init face-adja -- face )
    [ ] (intersection-into-face) ;

: intersections-into-faces ( face -- faces )
    clone dup  
    adjacent-faces>> [ intersection-into-face ] with map 
    [ ] filter ;

: (face-silhouette) ( face -- faces )
    clone dup adjacent-faces>>
    [   backface?
        [ intersection-into-silhouette-face ] [ 2drop f ]  if  
    ] with map 
    [ ] filter
; inline

: face-silhouette ( face -- faces )     
    backface? [ drop f ] [ (face-silhouette) ] if ;

! --------------------------------
! solid
! -------------------------------------------------------------
TUPLE: solid dimension silhouettes 
    faces corners adjacencies-valid color name ;

: <solid> ( -- tuple ) solid new ;

: suffix-silhouettes ( solid silhouette -- solid )  
    [ suffix ] curry change-silhouettes ;

: suffix-face ( solid face -- solid )     
    [ suffix ] curry change-faces ;
: suffix-corner ( solid corner -- solid ) 
    [ suffix ] curry change-corners ; 
: erase-solid-corners ( solid -- solid )  f >>corners ;

: erase-silhouettes ( solid -- solid ) 
    dup dimension>> f <array> >>silhouettes ;
: filter-real-faces ( solid -- solid ) 
    [ [ real-face? ] filter ] change-faces ;
: initiate-solid-from-face ( face -- solid ) 
    face-project-dim  <solid> swap >>dimension ;

: erase-old-adjacencies ( solid -- solid )
    erase-solid-corners
    [ dup [ erase-face-touching-corners 
        erase-face-adjacent-faces drop ] each ]
    change-faces ;

: point-inside-or-on-face? ( face v -- ? ) 
    [ halfspace>> ] dip point-inside-or-on-halfspace?  ;

: point-inside-face? ( face v -- ? ) 
    [ halfspace>> ] dip  point-inside-halfspace? ;

: point-inside-solid? ( solid point -- ? )
    [ faces>> ] dip [ point-inside-face? ] curry all? ; inline

: point-inside-or-on-solid? ( solid point -- ? )
    [ faces>> ] dip 
    [ point-inside-or-on-face? ] curry  all?   ; inline

: unvalid-adjacencies ( solid -- solid )  
    erase-old-adjacencies f >>adjacencies-valid 
    erase-silhouettes ;

: add-face ( solid face -- solid ) 
    suffix-face unvalid-adjacencies ; 

: cut-solid ( solid halfspace -- solid )    <face> add-face ; 

: slice-solid ( solid face  -- solid1 solid2 )
    [ [ clone ] bi@ flip-face add-face 
    [ "/outer/" append ] change-name  ] 2keep
    add-face [ "/inner/" append ] change-name ;

! -------------


: add-silhouette ( solid  -- solid )
   dup 
   ! find-adjacencies 
   faces>> { } 
   [ face-silhouette append ] reduce
   [ ] filter 
   <solid> 
        swap >>faces
        over dimension>> >>dimension 
        over name>> " silhouette " append 
                 pv> number>string append 
        >>name
     !   ensure-adjacencies
   suffix-silhouettes ; inline

: find-silhouettes ( solid -- solid )
    { } >>silhouettes 
    dup dimension>> [ [ add-silhouette ] with-pv ] each ;

: ensure-silhouettes ( solid  -- solid )
    dup  silhouettes>>  [ f = ] all?
    [ find-silhouettes  ]  when ; 

! ------------

: corner-added? ( solid corner -- ? ) 
    ! add corner to solid if it is inside solid
    [ ] 
    [ point-inside-or-on-solid? ] 
    [ swap corners>> member? not ] 
    2tri and
    [ suffix-corner drop t ] [ 2drop f ] if ;

: process-corner ( solid faces corner -- )
    swapd 
    [ corner-added? ] keep swap ! test if corner is inside solid
    [ update-adjacent-faces ] 
    [ 2drop ]
    if ;

: compute-intersection ( solid faces -- )
    dup faces-intersection
    dup f = [ 3drop ] [ process-corner ]  if ;

: test-faces-combinaisons ( solid n -- )
    [ dup faces>> ] dip among   
    [ compute-intersection ] with each ;

: compute-adjacencies ( solid -- solid )
    dup dimension>> [ >= ] curry 
    [ keep swap ] curry MAX-FACE-PER-CORNER swap
    [ [ test-faces-combinaisons ] 2keep 1- ] while drop ;

: find-adjacencies ( solid -- solid ) 
    erase-old-adjacencies   
    compute-adjacencies
    filter-real-faces 
    t >>adjacencies-valid ;

: ensure-adjacencies ( solid -- solid ) 
    dup adjacencies-valid>> 
    [ find-adjacencies ] unless 
    ensure-silhouettes
    ;

: (non-empty-solid?) ( solid -- ? ) 
    [ dimension>> ] [ corners>> length ] bi < ;
: non-empty-solid? ( solid -- ? )   
    ensure-adjacencies (non-empty-solid?) ;

: compare-corners-roughly ( corner corner -- ? )
    2drop t ;
! : remove-inner-faces ( -- ) ;
: face-project ( array face -- seq )
    backface? 
  [ 2drop f ]
    [   [ enlight-projection ] 
        [ initiate-solid-from-face ]
        [ intersections-into-faces ]  tri
        >>faces
        swap >>color        
    ]    if ;

: solid-project ( lights ambient solid -- solids )
  ensure-adjacencies
    [ color>> ] [ faces>> ] bi [ 3array  ] dip
    [ face-project ] with map 
    [ ] filter 
    [ ensure-adjacencies ] map
;

: (solid-move) ( solid v move -- solid ) 
   curry [ map ] curry 
   [ dup faces>> ] dip call drop  
   unvalid-adjacencies ; inline

: solid-translate ( solid v -- solid ) 
    [ face-translate ] (solid-move) ; 
: solid-transform ( solid m -- solid ) 
    [ face-transform ] (solid-move) ; 

: find-corner-in-silhouette ( s1 s2 -- elt bool )
    pv> swap silhouettes>> nth     
    swap corners>>
    [ point-inside-solid? ] with find swap ;

: valid-face-for-order ( solid point -- face )
    [ point-inside-face? not ] 
    [ drop face-orientation  0 = not ] 2bi and ;

: check-orientation ( s1 s2 pt -- int )
    [ nip faces>> ] dip
    [ valid-face-for-order ] curry find swap
    [ face-orientation ] [ drop f ] if ;

: (order-solid) ( s1 s2 -- int )
    2dup find-corner-in-silhouette
    [ check-orientation ] [ 3drop f ] if ;

: order-solid ( solid solid  -- i ) 
    2dup (order-solid)
    [ 2nip ]
    [   swap (order-solid)
        [ neg ] [ f ] if*
    ] if* ;

: subtract ( solid1 solid2 -- solids )
    faces>> swap clone ensure-adjacencies ensure-silhouettes  
    [ swap slice-solid drop ]  curry map
    [ non-empty-solid? ] filter
    [ ensure-adjacencies ] map
; inline

! -------------------------------------------------------------
! space 
! -------------------------------------------------------------
TUPLE: space name dimension solids ambient-color lights ;
: <space> ( -- space )      space new ;
: suffix-solids ( space solid -- space ) 
    [ suffix ] curry change-solids ; inline
: suffix-lights ( space light -- space ) 
    [ suffix ] curry change-lights ; inline
: clear-space-solids ( space -- space )     f >>solids ;

: space-ensure-solids ( space -- space ) 
    [ [ ensure-adjacencies ] map ] change-solids ;
: eliminate-empty-solids ( space -- space ) 
    [ [ non-empty-solid? ] filter ] change-solids ;

: projected-space ( space solids -- space ) 
   swap dimension>> 1-  <space>    
   swap >>dimension    swap  >>solids ;

: get-silhouette ( solid -- silhouette )    
    silhouettes>> pv> swap nth ;
: solid= ( solid solid -- ? )            [ corners>> ]  bi@ = ;

: space-apply ( space m quot -- space ) 
        curry [ map ] curry [ dup solids>> ] dip
        [ call ] [ 2drop ] recover drop ; inline
: space-transform ( space m -- space ) 
    [ solid-transform ] space-apply ;
: space-translate ( space v -- space ) 
    [ solid-translate ] space-apply ; 

: describe-space ( space -- ) 
    solids>>  
    [  [ corners>>  [ pprint ] each ] [ name>> . ] bi ] each ;

: clip-solid ( solid solid -- solids )
    [ ]
    [ solid= not ]
    [ order-solid -1 = ] 2tri 
    and
    [ get-silhouette subtract ] 
    [  drop 1array ] 
    if 
    
    ;

: (solids-silhouette-subtract) ( solids solid -- solids ) 
     [  clip-solid append ] curry { } -rot each ; inline

: solids-silhouette-subtract ( solids i solid -- solids )
! solids is an array of 1 solid arrays
      [ (solids-silhouette-subtract) ] curry map-but 
; inline 

: remove-hidden-solids ( space -- space ) 
! We must include each solid in a sequence because 
! during substration 
! a solid can be divided in more than on solid
    [ 
        [ [ 1array ] map ] 
        [ length ] 
        [ ] 
        tri     
        [ solids-silhouette-subtract ] 2each
        { } [ append ] reduce 
    ] change-solids
    eliminate-empty-solids ! TODO include into change-solids
;

: space-project ( space i -- space )
  [
  [ clone  
    remove-hidden-solids? [ remove-hidden-solids ] when
    dup 
        [ solids>> ] 
        [ lights>> ] 
        [ ambient-color>> ]  tri 
        [ rot solid-project ] 2curry 
        map 
        [ append ] { } -rot each 
        ! TODO project lights
        projected-space 
      ! remove-inner-faces 
      ! 
      eliminate-empty-solids
    ] with-pv 
    ] [ 3drop <space> ] recover
    ; inline

: middle-of-space ( space -- point )
    solids>> [ corners>> ] map concat
    [ [ ] [ v+ ] map-reduce ] [ length ] bi v/n
;

! -------------------------------------------------------------
! 3D rendering
! -------------------------------------------------------------

: face-reference ( face -- halfspace point vect )
       [ halfspace>> ] 
       [ touching-corners>> first ] 
       [ touching-corners>> second ] tri 
       over v-
;

: theta ( v halfspace point vect -- v x )
   [ [ over ] dip v- ] dip    
   [ cross dup norm >float ]
   [ v. >float ]  
   2bi 
   fatan2
   -rot v. 
   0 < [ neg ] when
;

: ordered-face-points ( face -- corners )  
    [ touching-corners>> 1 head ] 
    [ touching-corners>> 1 tail ] 
    [ face-reference [ theta ] 3curry ]         tri
    { } map>assoc    sort-values keys 
    append
    ; inline

: point->GL  ( point -- )   gl-vertex ;
: points->GL ( array -- )   do-cycle [ point->GL ] each ;

: face->GL ( face color -- )
   [ ordered-face-points ] dip
   [ first3 1.0 glColor4d GL_POLYGON 
        [ [ point->GL  ] each ] do-state ] curry
   [  0 0 0 1 glColor4d GL_LINE_LOOP 
        [ [ point->GL  ] each ] do-state ]
   bi
   ; inline

: solid->GL ( solid -- )    
    [ faces>> ]    
    [ color>> ] bi
    [ face->GL ] curry each ; inline

: space->GL ( space -- )
    solids>>
    [ solid->GL ] each ;





