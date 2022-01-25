! Copyright (C) 2010 Slava Pestov.
USING: gml.types gml.printer gml.runtime math math.constants
math.functions math.matrices math.order ranges math.trig
math.vectors continuations combinators arrays kernel vectors
accessors prettyprint fry sequences assocs locals hashtables
grouping sorting classes.struct math.vectors.simd
math.vectors.simd.cords random random.mersenne-twister
system namespaces ;
IN: gml.coremath

! :: gml-scalar-op ( a b scalar-quot mixed-quot vector-quot -- c )
!     {
!         { [ b float? ] [ a b scalar-quot call ] }
!         { [ b integer? ] [ a b scalar-quot call ] }
!         { [ b vec2d? ] [ a scalar>vec2d b mixed-quot call ] }
!         { [ b vec3d? ] [ a scalar>vec3d b mixed-quot call ] }
!     } cond ; inline
!
! :: gml-math-op ( a b scalar-quot mixed-quot vector-quot -- c )
!     {
!         { [ a float? ] [ a b scalar-quot mixed-quot vector-quot gml-scalar-op ] }
!         { [ a integer? ] [ a b scalar-quot mixed-quot vector-quot gml-scalar-op ] }
!         { [ a vec2d? ] [
!             {
!                 { [ b vec2d? ] [ a b vector-quot call ] }
!                 { [ b float? ] [ a b scalar>vec2d mixed-quot call ] }
!                 { [ b integer? ] [ a b scalar>vec2d mixed-quot call ] }
!             } cond
!         ] }
!         { [ a vec3d? ] [
!             {
!                 { [ b vec3d? ] [ a b vector-quot call ] }
!                 { [ b float? ] [ a b scalar>vec3d mixed-quot call ] }
!                 { [ b integer? ] [ a b scalar>vec3d mixed-quot call ] }
!             } cond
!         ] }
!     } cond ; inline

! Don't use locals here until a limitation in the propagation pass
! is fixed (constraints on slots). Maybe optimizing GML math ops
! like this isn't worth it anyway, since GML is interpreted
FROM: generalizations => npick ;

: gml-scalar-op ( a b scalar-quot mixed-quot vector-quot -- c )
    {
        { [ reach float? ] [ 2drop call ] }
        { [ reach integer? ] [ 2drop call ] }
        { [ reach vec2d? ] [ drop nip [ scalar>vec2d ] 2dip call ] }
        { [ reach vec3d? ] [ drop nip [ scalar>vec3d ] 2dip call ] }
    } cond ; inline

: gml-math-op ( a b scalar-quot mixed-quot vector-quot -- c )
    {
        { [ 5 npick float? ] [ gml-scalar-op ] }
        { [ 5 npick integer? ] [ gml-scalar-op ] }
        { [ 5 npick vec2d? ] [
            {
                { [ reach vec2d? ] [ 2nip call ] }
                { [ reach float? ] [ drop nip [ scalar>vec2d ] dip call ] }
                { [ reach integer? ] [ drop nip [ scalar>vec2d ] dip call ] }
            } cond
        ] }
        { [ 5 npick vec3d? ] [
            {
                { [ reach vec3d? ] [ 2nip call ] }
                { [ reach float? ] [ drop nip [ scalar>vec3d ] dip call ] }
                { [ reach integer? ] [ drop nip [ scalar>vec3d ] dip call ] }
            } cond
        ] }
    } cond ; inline

GML: add ( a b -- c ) [ + ] [ v+ ] [ v+ ] gml-math-op ;
GML: sub ( a b -- c ) [ - ] [ v- ] [ v- ] gml-math-op ;
GML: mul ( a b -- c ) [ * ] [ v* ] [ vdot ] gml-math-op ;
GML: div ( a b -- c ) [ /f ] [ v/ mask-vec3d ] [ v/ mask-vec3d ] gml-math-op ;
GML: mod ( a b -- c ) mod ;

GML: neg ( x -- y )
    {
        { [ dup integer? ] [ neg ] }
        { [ dup float? ] [ neg ] }
        { [ dup vec2d? ] [ vneg ] }
        { [ dup vec3d? ] [ vneg mask-vec3d ] }
    } cond ;

GML: eq ( a b -- c ) = >true ;
GML: ne ( a b -- c ) = not >true ;
GML: ge ( a b -- c ) >= >true ;
GML: gt ( a b -- c ) > >true ;
GML: le ( a b -- c ) <= >true ;
GML: lt ( a b -- c ) < >true ;

! Trig
GML: sin ( x -- y ) >float deg>rad sin ;
GML: asin ( x -- y ) >float asin rad>deg ;
GML: cos ( x -- y ) >float deg>rad cos ;
GML: acos ( x -- y ) >float acos rad>deg ;
GML: tan ( x -- y ) >float deg>rad tan ;
GML: atan ( x -- y ) >float atan rad>deg ;

FROM: math.libm => fatan2 ;
GML: atan2 ( x y -- z ) [ >float ] bi@ fatan2 rad>deg ;

GML: pi ( -- pi ) pi ;

! Bitwise ops
: logical-op ( a b quot -- c ) [ [ true? ] bi@ ] dip call >true ; inline

GML: and ( a b -- c ) [ and ] logical-op ;
GML: or ( a b -- c ) [ or ] logical-op ;
GML: not ( a -- b ) 0 number= >true ;

! Misc functions
GML: abs ( x -- y )
    {
        { [ dup integer? ] [ abs ] }
        { [ dup float? ] [ abs ] }
        { [ dup vec2d? ] [ norm ] }
        { [ dup vec3d? ] [ norm ] }
    } cond ;

: must-be-positive ( x -- x ) dup 0 < [ "Domain error" throw ] when ; inline

GML: sqrt ( x -- y ) must-be-positive sqrt ;
GML: inv ( x -- y ) >float recip ;
GML: log ( x -- y ) must-be-positive log10 ;
GML: ln ( x -- y ) must-be-positive log ;
GML: exp ( x -- y ) e^ ;
GML: pow ( x y -- z ) [ >float ] bi@ ^ ;

GML: ceiling ( x -- y ) ceiling ;
GML: floor ( x -- y ) floor ;
GML: trunc ( x -- y ) truncate ;
GML: round ( x -- y ) round ;

GML: clamp ( x v -- y ) first2 clamp ;

! Vector functions
GML: getX ( vec -- x )
    {
        { [ dup vec2d? ] [ first ] }
        { [ dup vec3d? ] [ first ] }
    } cond ;

GML: getY ( vec -- x )
    {
        { [ dup vec2d? ] [ second ] }
        { [ dup vec3d? ] [ second ] }
    } cond ;

GML: getZ ( vec -- x )
    {
        { [ dup vec3d? ] [ third ] }
    } cond ;

GML: putX ( vec x -- x )
    {
        { [ over vec2d? ] [ [ second ] dip swap <vec2d> ] }
        { [ over vec3d? ] [ [ [ second ] [ third ] bi ] dip -rot <vec3d> ] }
    } cond ;

GML: putY ( vec y -- x )
    {
        { [ over vec2d? ] [ [ first ] dip <vec2d> ] }
        { [ over vec3d? ] [ [ [ first ] [ third ] bi ] dip swap <vec3d> ] }
    } cond ;

GML: putZ ( vec z -- x )
    {
        { [ over vec3d? ] [ [ first2 ] dip <vec3d> ] }
    } cond ;

GML: dist ( u v -- x ) distance ;

GML: normalize ( u -- v ) normalize mask-vec3d ;

GML: planemul ( u v p -- w )
    first2 [ v*n ] bi-curry@ bi* v+ ;

GML: cross ( u v -- w ) cross ;

: normal ( vec -- norm )
    [ first double-4{ 0 1 0 0 } n*v ]
    [ second double-4{ -1 0 0 0 } n*v ]
    [ third double-4{ -1 0 0 0 } n*v ] tri v+ v+ ; inline

GML: aNormal ( x -- y )
    {
        { [ dup vec2d? ] [ normalize double-2{ 1 -1 } v* { 1 0 } vshuffle ] }
        { [ dup vec3d? ] [ normalize normal ] }
    } cond ;

: det2 ( x y -- z )
    { 1 0 } vshuffle double-2{ 1 -1 } v* vdot ; inline

: det3 ( x y z -- w )
    [ cross ] dip vdot ; inline

GML: determinant ( x -- y )
    {
        { [ dup vec2d? ] [ [ dup pop-operand ] dip det2 ] }
        { [ dup vec3d? ] [ [ dup [ pop-operand ] [ pop-operand ] bi swap ] dip det3 ] }
    } cond ;

GML: vector2 ( x y -- v ) <vec2d> ;

GML: vector3 ( x y z -- v ) <vec3d> ;

GML: random ( -- x ) 0.0 1.0 uniform-random-float ;

GML: randomseed ( n -- )
    dup 0 < [ drop nano-count 1000000 /i ] when
    <mersenne-twister> random-generator set ;

! Extensions to real GML
GML: approx-eq ( a b -- c )
    [ 10e-5 ~ ] [ 10e-5 v~ ] [ 10e-5 v~ ] gml-math-op >true ;
