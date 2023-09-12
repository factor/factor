! Copyright (c) 2012 Anonymous
! See https://factorcode.org/license.txt for BSD license.
USING: arrays kernel math math.functions
math.vectors sequences ;
IN: rosetta-code.haversine-formula

! https://rosettacode.org/wiki/Haversine_formula

! The haversine formula is an equation important in navigation,
! giving great-circle distances between two points on a sphere
! from their longitudes and latitudes. It is a special case of a
! more general formula in spherical trigonometry, the law of
! haversines, relating the sides and angles of spherical
! "triangles".

! Task: Implement a great-circle distance function, or use a
! library function, to show the great-circle distance between
! Nashville International Airport (BNA) in Nashville, TN, USA: N
! 36°7.2', W 86°40.2' (36.12, -86.67) and Los Angeles
! International Airport (LAX) in Los Angeles, CA, USA: N 33°56.4',
! W 118°24.0' (33.94, -118.40).

CONSTANT: R_earth 6372.8 ! in kilometers

: haversin ( x -- y ) cos 1 swap - 2 / ;

: haversininv ( y -- x ) 2 * 1 swap - acos ;

: haversineDist ( as bs -- d )
    [ [ deg>rad ] map ] bi@
    [ [ swap - haversin ] 2map ]
    [ [ first cos ] bi@ * 1 swap 2array ]
    2bi
    vdot
    haversininv R_earth * ;
