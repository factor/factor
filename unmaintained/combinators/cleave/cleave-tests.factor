
USING: kernel math math.functions tools.test combinators.cleave ;

IN: combinators.cleave.tests

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: unit-test* ( input output -- ) swap unit-test ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

[ { [ 1 ] [ 2 ] [ 3 ] [ 4 ] } 0arr ]       [ { 1 2 3 4 } ] unit-test*

[ 3 { 1+ 1- 2^ } 1arr ]                    [ { 4 2 8 } ]   unit-test*

[ 3 4 { [ + ] [ - ] [ ^ ] } 2arr ]         [ { 7 -1 81 } ] unit-test*

[ 1 2 3 { [ + + ] [ - - ] [ * * ] } 3arr ] [ { 6 2 6 } ]   unit-test*

