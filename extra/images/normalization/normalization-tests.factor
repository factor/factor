! BSD License. Copyright 2009 Keith Lazuka
USING: images images.normalization images.normalization.private
sequences tools.test ;
IN: images.normalization.tests

! R

[ B{ 0 255 255 255 1 255 255 255 } ]
[ B{ 0 1 } R RGBA permute ] unit-test

[ B{ 255 255 0 255 255 1 } ]
[ B{ 0 1 } R BGR permute ] unit-test

[ B{ 255 255 0 255 255 255 1 255 } ]
[ B{ 0 1 } R BGRA permute ] unit-test

[ B{ 255 0 255 255 255 1 255 255 } ]
[ B{ 0 1 } R ARGB permute ] unit-test

! RGB

[ B{ 0 3 } ]
[ B{ 0 1 2 3 4 5 } RGB R permute ] unit-test

[ B{ 0 1 2 255 3 4 5 255 } ]
[ B{ 0 1 2 3 4 5 } RGB RGBA permute ] unit-test

[ B{ 2 1 0 5 4 3 } ]
[ B{ 0 1 2 3 4 5 } RGB BGR permute ] unit-test

[ B{ 2 1 0 255 5 4 3 255 } ]
[ B{ 0 1 2 3 4 5 } RGB BGRA permute ] unit-test

[ B{ 255 0 1 2 255 3 4 5 } ]
[ B{ 0 1 2 3 4 5 } RGB ARGB permute ] unit-test

! RGBA

[ B{ 0 4 } ]
[ B{ 0 1 2 3 4 5 6 7 } RGBA R permute ] unit-test

[ B{ 0 1 2 4 5 6 } ]
[ B{ 0 1 2 3 4 5 6 7 } RGBA RGB permute ] unit-test

[ B{ 2 1 0 6 5 4 } ]
[ B{ 0 1 2 3 4 5 6 7 } RGBA BGR permute ] unit-test

[ B{ 2 1 0 3 6 5 4 7 } ]
[ B{ 0 1 2 3 4 5 6 7 } RGBA BGRA permute ] unit-test

[ B{ 3 0 1 2 7 4 5 6 } ]
[ B{ 0 1 2 3 4 5 6 7 } RGBA ARGB permute ] unit-test

! BGR

[ B{ 2 1 0 5 4 3 } ]
[ B{ 0 1 2 3 4 5 } BGR RGB permute ] unit-test

[ B{ 2 1 0 255 5 4 3 255 } ]
[ B{ 0 1 2 3 4 5 } BGR RGBA permute ] unit-test

[ B{ 0 1 2 255 3 4 5 255 } ]
[ B{ 0 1 2 3 4 5 } BGR BGRA permute ] unit-test

[ B{ 255 2 1 0 255 5 4 3 } ]
[ B{ 0 1 2 3 4 5 } BGR ARGB permute ] unit-test

! BGRA

[ B{ 2 1 0 6 5 4 } ]
[ B{ 0 1 2 3 4 5 6 7 } BGRA RGB permute ] unit-test

[ B{ 0 1 2 4 5 6 } ]
[ B{ 0 1 2 3 4 5 6 7 } BGRA BGR permute ] unit-test

[ B{ 2 1 0 3 6 5 4 7 } ]
[ B{ 0 1 2 3 4 5 6 7 } BGRA RGBA permute ] unit-test

[ B{ 3 2 1 0 7 6 5 4 } ]
[ B{ 0 1 2 3 4 5 6 7 } BGRA ARGB permute ] unit-test

! ARGB

[ B{ 1 2 3 5 6 7 } ]
[ B{ 0 1 2 3 4 5 6 7 } ARGB RGB permute ] unit-test

[ B{ 3 2 1 7 6 5 } ]
[ B{ 0 1 2 3 4 5 6 7 } ARGB BGR permute ] unit-test

[ B{ 3 2 1 0 7 6 5 4 } ]
[ B{ 0 1 2 3 4 5 6 7 } ARGB BGRA permute ] unit-test

[ B{ 1 2 3 0 5 6 7 4 } ]
[ B{ 0 1 2 3 4 5 6 7 } ARGB RGBA permute ] unit-test

