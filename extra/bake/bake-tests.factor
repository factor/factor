
USING: kernel tools.test bake ;

IN: bake.tests

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: unit-test* ( input output -- ) swap unit-test ;

: must-be-t ( in -- ) [ t ] swap unit-test ;
: must-be-f ( in -- ) [ f ] swap unit-test ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

[ 10 20 30 `{ , , , } ] [ { 10 20 30 } ] unit-test*

[ 10 20 30 `{ , { , } , } ] [ { 10 { 20 } 30 } ] unit-test*

[ 10 { 20 21 22 } 30 `{ , , , } ] [ { 10 { 20 21 22 } 30 } ] unit-test*

[ 10 { 20 21 22 } 30 `{ , @ , } ] [ { 10 20 21 22 30 } ] unit-test*

[ { 1 2 3 } `{ @ } ] [ { 1 2 3 } ] unit-test*

[ { 1 2 3 } { 4 5 6 } { 7 8 9 } `{ @ @ @ } ]
[ { 1 2 3 4 5 6 7 8 9 } ]
unit-test*

