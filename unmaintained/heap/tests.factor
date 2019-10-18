! Binary Min Heap
! Copyright 2007 Ryan Murphy
! See http://factorcode.org/license.txt for BSD license.

USING: heap test kernel ;

{ 1 2 3 4 5 6 } [ 0 left 0 right 1 left 1 right 2 left 2 right ] unit-test
{ t } [ 5 3 [comp] ] unit-test
{ V{ } } [ <heap> ] unit-test

{ V{ -6 -4 2 1 5 3 2 4 3 7 6 8 3 4 4 6 5 5 } } [ <heap> { 3 5 4 6 7 8 2 4 3 5 6 1 3 2 4 5 -6 -4 } over add-many ] unit-test



{ V{ "hire" "hose" } } [ V{ "hi" "ho" } V{ "re" "se" } aggregate2 ] unit-test
{ V{ "hire" "hose" "  it" } } [ V{ "hi" "ho" } V{ "re" "se" "it" } aggregate2 ] unit-test
{ V{ "tracks" "snacks" "crack " } } [ V{ "track" "snack" "crack" } V{ "s" "s" } aggregate2 ] unit-test



{ V{ "    top     " "left   right" } } [ V{ "left" } V{ "right" } V{ "top" } aggregate3 ] unit-test

{ V{ "    top     "
     "    dog     "
     "left   right"
     "over   on   "
     "       man  " } } [ V{ "left" "over" } V{ "right" "on   " "man  " } V{ "top" "dog" } aggregate3 ] unit-test

{ V{ "           -6       "
     "      -4        2   "
     "   1     5    3   2 "
     " 4   3  7 6  8 3 4 4"
     "6 5 5               " } } [ 0 <heap> { 3 5 4 6 7 8 2 4 3 5 6 1 3 2 4 5 -6 -4 } over add-many (print-heap) ] unit-test

{ V{ 5 6 6 7 8 } } [ <heap> { 3 5 4 6 5 7 6 8 } over add-many dup bump dup bump dup bump ] unit-test