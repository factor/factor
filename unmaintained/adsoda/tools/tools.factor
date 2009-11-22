! Copyright (C) 2008 Jeff Bigot
! See http://factorcode.org/license.txt for BSD license.
USING: 
kernel
sequences
math
accessors
adsoda
math.vectors 
math.matrices
bunny.model
io.encodings.ascii
io.files
sequences.deep
combinators
adsoda.combinators
fry
io.files.temp
grouping
;

IN: adsoda.tools





! ---------------------------------
: coord-min ( x array -- array )  swap suffix  ;
: coord-max ( x array -- array )  swap neg suffix ;

: 4cube ( array name -- solid )
! array : xmin xmax ymin ymax zmin zmax wmin wmax
    <solid> 
    4 >>dimension
    swap >>name
    swap
    { 
       [ { 1 0 0 0 } coord-min ] [ { -1 0 0 0 } coord-max ] 
       [ { 0 1 0 0 } coord-min ] [ { 0 -1 0 0 } coord-max ]
       [ { 0 0 1 0 } coord-min ] [ { 0 0 -1 0 } coord-max ] 
       [ { 0 0 0 1 } coord-min ] [ { 0 0 0 -1 } coord-max ]
    }
    [ curry call ] 2map 
    [ cut-solid ] each 
    ensure-adjacencies
    
; inline

: 3cube ( array name -- solid )
! array : xmin xmax ymin ymax zmin zmax wmin wmax
    <solid> 
    3 >>dimension
    swap >>name
    swap
    { 
       [ { 1 0 0 } coord-min ] [ { -1 0 0 } coord-max ] 
       [ { 0 1 0 } coord-min ] [ { 0 -1 0 } coord-max ]
       [ { 0 0 1 } coord-min ] [ { 0 0 -1 } coord-max ] 
    }
    [ curry call ] 2map 
    [ cut-solid ] each 
    ensure-adjacencies
    
; inline


: equation-system-for-normal ( points -- matrix )
    unclip [ v- 0 suffix ] curry map
    dup first [ drop 1 ] map     suffix
;

: normal-vector ( points -- v ) 
    equation-system-for-normal
    intersect-hyperplanes ;

: points-to-hyperplane ( points -- hyperplane )
    [ normal-vector 0 suffix ] [ first ] bi
    translate ;

: refs-to-points ( points faces -- faces )
   [ swap [ nth 10 v*n { 100 100 100 } v+ ] curry map ] 
   with map
;
! V{ { 0.1 0.2 } { 1.1 1.3 } } V{ { 1 0 } { 0 1 } }
! V{ { { 1.1 1.3 } { 0.1 0.2 } } { { 0.1 0.2 } { 1.1 1.3 } } }

: ply-model-path ( -- path )

! "bun_zipper.ply" 
"screw2.ply"
temp-file 
;

: read-bunny-model ( -- v )
ply-model-path ascii [  parse-model ] with-file-reader

refs-to-points
;

: 3points-to-normal ( seq -- v )
    unclip [ v- ] curry map first2 cross normalize
;
: 2-faces-to-prism ( seq seq -- seq )
  2dup
    [ do-cycle 2 clump ] bi@ concat-nth  
    !  3 faces rectangulaires
    swap prefix
    swap prefix
;    

: Xpoints-to-prisme ( seq height -- cube )
    ! from 3 points gives a list of faces representing 
    ! a cube of height "height"
    ! and of based on the three points
    ! a face is a group of 3 or mode points.   
    [ dup dup  3points-to-normal ] dip 
    v*n [ v+ ] curry map ! 2 eme face triangulaire 
    2-faces-to-prism  

! [ dup number? [ 1 + ] when ] deep-map
! dup keep 
;


: Xpoints-to-plane4D ( seq x y -- 4Dplane )
    ! from 3 points gives a list of faces representing 
    ! a cube in 4th dim
    ! from x to y (height = y-x)
    ! and of based on the X points
    ! a face is a group of 3 or mode points.   
    '[ [ [ _ suffix ] map ] [ [ _ suffix ] map ] bi ] call
    2-faces-to-prism
;

: 3pointsfaces-to-3Dsolidfaces ( seq -- seq )
    [ 1 Xpoints-to-prisme [ 100 
        110 Xpoints-to-plane4D ] map concat ] map 

;

: test-figure ( -- solid )
    <solid> 
    2 >>dimension
    { 1 -1 -5 } cut-solid 
    { -1 -1 -21 } cut-solid 
    { -1 0 -12 } cut-solid 
    { 1 2 16 } cut-solid
;

