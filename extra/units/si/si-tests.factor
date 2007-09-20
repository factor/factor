USING: kernel tools.test units.si inverse ;
IN: temporary

[ t ] [ 1 m 100 cm = ] unit-test

[ t ] [ 180 arc-deg [ radians ] undo pi 0.0001 ~ ] unit-test

[ t ] [ 180 arc-min [ arc-deg ] undo 3 0.0001 ~ ] unit-test

[ -40 ] [ -40 deg-F [ deg-C ] undo ] unit-test

[ -40 ] [ -40 deg-C [ deg-F ] undo ] unit-test
