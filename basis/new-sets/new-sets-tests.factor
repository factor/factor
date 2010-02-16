! Copyright (C) 2010 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: new-sets tools.test kernel sorting prettyprint bit-arrays arrays ;
IN: new-sets.tests

[ { } ] [ { } { } intersect  ] unit-test
[ { 2 3 } ] [ { 1 2 3 } { 2 3 4 } intersect ] unit-test

[ { } ] [ { } { } diff ] unit-test
[ { 1 } ] [ { 1 2 3 } { 2 3 4 } diff ] unit-test

[ { } ] [ { } { } union ] unit-test
[ { 1 2 3 4 } ] [ { 1 2 3 } { 2 3 4 } union ] unit-test

[ t ] [ { 1 2 } { 1 3 } intersects? ] unit-test

[ f ] [ { 4 2 } { 1 3 } intersects? ] unit-test

[ f ] [ { } { 1 } intersects? ] unit-test

[ f ] [ { 1 } { } intersects? ] unit-test

[ t ] [ 4 { 2 4 5 } in? ] unit-test
[ f ] [ 1 { 2 4 5 } in? ] unit-test

[ V{ 1 2 3 } ] [ 3 V{ 1 2 } clone [ adjoin ] keep ] unit-test
[ V{ 1 2 } ] [ 2 V{ 1 2 } clone [ adjoin ] keep ] unit-test
[ V{ 1 2 } ] [ 3 V{ 1 2 } clone [ delete ] keep ] unit-test
[ V{ 2 } ] [ 1 V{ 1 2 } clone [ delete ] keep ] unit-test

[ t ] [ { 1 2 3 } { 2 1 3 } set= ] unit-test
[ f ] [ { 2 3 } { 1 2 3 } set= ] unit-test
[ f ] [ { 1 2 3 } { 2 3 } set= ] unit-test

[ { 1 } ] [ { 1 } members ] unit-test

[ { 1 2 3 } ] [ { 1 1 1 2 2 3 3 3 3 3 } dup set-like natural-sort ] unit-test
[ { 1 2 3 } ] [ HS{ 1 2 3 } { } set-like natural-sort ] unit-test

[ HS{ 1 2 3 } ] [ { 1 2 3 } fast-set ] unit-test

[ { 1 2 3 } ] [ HS{ 1 2 3 } members natural-sort ] unit-test

[ "HS{ 1 2 3 4 }" ] [ HS{ 1 2 3 4 } unparse ] unit-test

[ t ] [ 1 HS{ 0 1 2 } in? ] unit-test
[ f ] [ 3 HS{ 0 1 2 } in? ] unit-test
[ HS{ 1 2 3 } ] [ 3 HS{ 1 2 } clone [ adjoin ] keep ] unit-test
[ HS{ 1 2 } ] [ 2 HS{ 1 2 } clone [ adjoin ] keep ] unit-test
[ HS{ 1 2 3 } ] [ 4 HS{ 1 2 3 } clone [ delete ] keep ] unit-test
[ HS{ 1 2 } ] [ 3 HS{ 1 2 3 } clone [ delete ] keep ] unit-test
[ HS{ 1 2 } ] [ HS{ 1 2 } fast-set ] unit-test
[ { 1 2 } ] [ HS{ 1 2 } members natural-sort ] unit-test

[ HS{ 1 2 3 4 } ] [ HS{ 1 2 3 } HS{ 2 3 4 } union ] unit-test
[ HS{ 2 3 } ] [ HS{ 1 2 3 } HS{ 2 3 4 } intersect ] unit-test
[ t ] [ HS{ 1 2 3 } HS{ 2 3 4 } intersects? ] unit-test
[ f ] [ HS{ 1 } HS{ 2 3 4 } intersects? ] unit-test
[ f ] [ HS{ 1 } HS{ 2 3 4 } subset? ] unit-test
[ f ] [ HS{ 1 2 3 } HS{ 2 3 4 } subset? ] unit-test
[ t ] [ HS{ 2 3 } HS{ 2 3 4 } subset? ] unit-test
[ t ] [ HS{ } HS{ 2 3 4 } subset? ] unit-test
[ HS{ 1 } ] [ HS{ 1 2 3 } HS{ 2 3 4 } diff ] unit-test
[ t ] [ HS{ 1 2 3 } HS{ 2 1 3 } set= ] unit-test
[ t ] [ HS{ 1 2 3 } HS{ 2 1 3 } = ] unit-test
[ f ] [ HS{ 2 3 } HS{ 2 1 3 } set= ] unit-test
[ f ] [ HS{ 1 2 3 } HS{ 2 3 } set= ] unit-test

[ HS{ 1 2 } HS{ 1 2 3 } ] [ HS{ 1 2 } clone dup clone [ 3 swap adjoin ] keep ] unit-test
