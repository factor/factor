USING: accessors colors colors.hsv kernel math tools.test ;
IN: colors.hsv.tests

: hsv>rgb ( h s v -- r g b )
    [ 360 * ] 2dip
    1 <hsva> >rgba [ red>> ] [ green>> ] [ blue>> ] tri ;

{ 1/2 1/2 1/2 } [ 0 0 1/2 hsv>rgb ] unit-test

{ 1/2 1/4 1/4 } [ 0 1/2 1/2 hsv>rgb ] unit-test
{ 1/3 2/9 2/9 } [ 0 1/3 1/3 hsv>rgb ] unit-test

{ 24/125 1/5 4/25 } [ 1/5 1/5 1/5 hsv>rgb ] unit-test
{ 29/180 1/6 5/36 } [ 1/5 1/6 1/6 hsv>rgb ] unit-test

{ 6/25 2/5 38/125 } [ 2/5 2/5 2/5 hsv>rgb ] unit-test
{ 8/25 4/5 64/125 } [ 2/5 3/5 4/5 hsv>rgb ] unit-test

{ 6/25 48/125 3/5 } [ 3/5 3/5 3/5 hsv>rgb ] unit-test
{ 0 0 0 } [ 3/5 1/5 0 hsv>rgb ] unit-test

{ 84/125 4/25 4/5 } [ 4/5 4/5 4/5 hsv>rgb ] unit-test
{ 7/15 1/3 1/2 } [ 4/5 1/3 1/2 hsv>rgb ] unit-test

{ 5/6 5/36 5/6 } [ 5/6 5/6 5/6 hsv>rgb ] unit-test
{ 1/6 0 1/6 } [ 5/6 1 1/6 hsv>rgb ] unit-test

{ 0.5 } [ 180 0.1 0.2 0.5 <hsva> alpha>> ] unit-test
