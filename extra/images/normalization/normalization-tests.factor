! BSD License. Copyright 2009 Keith Lazuka
USING: images.normalization images.normalization.private
sequences tools.test ;
IN: images.normalization.tests

! RGB

[ B{ 0 1 2 255 3 4 5 255 } ]
[ B{ 0 1 2 3 4 5 } RGB>RGBA ] unit-test

[ B{ 2 1 0 5 4 3 } ]
[ B{ 0 1 2 3 4 5 } RGB>BGR ] unit-test

[ B{ 2 1 0 255 5 4 3 255 } ]
[ B{ 0 1 2 3 4 5 } RGB>BGRA ] unit-test

[ B{ 255 0 1 2 255 3 4 5 } ]
[ B{ 0 1 2 3 4 5 } RGB>ARGB ] unit-test

! RGBA

[ B{ 0 1 2 4 5 6 } ]
[ B{ 0 1 2 3 4 5 6 7 } RGBA>RGB ] unit-test

[ B{ 2 1 0 6 5 4 } ]
[ B{ 0 1 2 3 4 5 6 7 } RGBA>BGR ] unit-test

[ B{ 2 1 0 3 6 5 4 7 } ]
[ B{ 0 1 2 3 4 5 6 7 } RGBA>BGRA ] unit-test

[ B{ 3 0 1 2 7 4 5 6 } ]
[ B{ 0 1 2 3 4 5 6 7 } RGBA>ARGB ] unit-test

! BGR

[ B{ 2 1 0 5 4 3 } ]
[ B{ 0 1 2 3 4 5 } BGR>RGB ] unit-test

[ B{ 2 1 0 255 5 4 3 255 } ]
[ B{ 0 1 2 3 4 5 } BGR>RGBA ] unit-test

[ B{ 0 1 2 255 3 4 5 255 } ]
[ B{ 0 1 2 3 4 5 } BGR>BGRA ] unit-test

[ B{ 255 2 1 0 255 5 4 3 } ]
[ B{ 0 1 2 3 4 5 } BGR>ARGB ] unit-test

! BGRA

[ B{ 2 1 0 6 5 4 } ]
[ B{ 0 1 2 3 4 5 6 7 } BGRA>RGB ] unit-test

[ B{ 0 1 2 4 5 6 } ]
[ B{ 0 1 2 3 4 5 6 7 } BGRA>BGR ] unit-test

[ B{ 2 1 0 3 6 5 4 7 } ]
[ B{ 0 1 2 3 4 5 6 7 } BGRA>RGBA ] unit-test

[ B{ 3 2 1 0 7 6 5 4 } ]
[ B{ 0 1 2 3 4 5 6 7 } BGRA>ARGB ] unit-test

! ARGB

[ B{ 1 2 3 5 6 7 } ]
[ B{ 0 1 2 3 4 5 6 7 } ARGB>RGB ] unit-test

[ B{ 3 2 1 7 6 5 } ]
[ B{ 0 1 2 3 4 5 6 7 } ARGB>BGR ] unit-test

[ B{ 3 2 1 0 7 6 5 4 } ]
[ B{ 0 1 2 3 4 5 6 7 } ARGB>BGRA ] unit-test

[ B{ 1 2 3 0 5 6 7 4 } ]
[ B{ 0 1 2 3 4 5 6 7 } ARGB>RGBA ] unit-test


