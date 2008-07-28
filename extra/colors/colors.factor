! Copyright (C) 2003, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.

USING: kernel combinators sequences arrays
       classes.tuple multi-methods accessors colors.hsv ;

IN: colors

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: color ;

TUPLE: rgba < color red green blue alpha ;

TUPLE: hsva < color hue saturation value alpha ;

TUPLE: grey < color grey alpha ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

GENERIC: >rgba ( object -- rgba )

METHOD: >rgba { rgba } ;

METHOD: >rgba { hsva }
  { [ hue>> ] [ saturation>> ] [ value>> ] [ alpha>> ] } cleave 4array
  [ hsv>rgb ] [ peek ] bi suffix first4 rgba boa ;

METHOD: >rgba { grey } [ grey>> dup dup ] [ alpha>> ] bi rgba boa ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

USE: syntax

M: color red>>   >rgba red>> ;
M: color green>> >rgba green>> ;
M: color blue>>  >rgba blue>> ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: black { 0.0 0.0 0.0 1.0 } ;
: blue { 0.0 0.0 1.0 1.0 } ;
: cyan { 0 0.941 0.941 1 } ;
: gray { 0.6 0.6 0.6 1.0 } ;
: green { 0.0 1.0 0.0 1.0 } ;
: light-gray { 0.95 0.95 0.95 0.95 } ;
: light-purple { 0.8 0.8 1.0 1.0 } ;
: magenta { 0.941 0 0.941 1 } ;
: orange  { 0.941 0.627 0 1 } ;
: purple  { 0.627 0 0.941 1 } ;
: red { 1.0 0.0 0.0 1.0 } ;
: white { 1.0 1.0 1.0 1.0 } ;
: yellow { 1.0 1.0 0.0 1.0 } ;
