! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test ui.text fonts math accessors kernel sequences ;
IN: ui.text.tests

[ t ] [ 0 sans-serif-font "aaa" offset>x zero? ] unit-test
[ t ] [ 1 sans-serif-font "aaa" offset>x 0.0 > ] unit-test
[ t ] [ 3 sans-serif-font "aaa" offset>x 0.0 > ] unit-test
[ t ] [ 1 monospace-font "a" offset>x 0.0 > ] unit-test
[ 0 ] [ 0 sans-serif-font "aaa" x>offset ] unit-test
[ 3 ] [ 100 sans-serif-font "aaa" x>offset ] unit-test
[ 0 ] [ 0 sans-serif-font "" x>offset ] unit-test

[ t ] [
    sans-serif-font "aaa" line-metrics
    [ [ ascent>> ] [ descent>> ] bi + ] [ height>> ] bi =
] unit-test

[ f ] [ sans-serif-font "\0a" text-dim first zero? ] unit-test
[ t ] [ sans-serif-font "" text-dim first zero? ] unit-test

[ f ] [ sans-serif-font font-metrics height>> zero? ] unit-test
