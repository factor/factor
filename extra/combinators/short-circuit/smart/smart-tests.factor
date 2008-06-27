
USING: kernel math tools.test combinators.short-circuit.smart ;

IN: combinators.short-circuit.smart.tests

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: must-be-t ( in -- ) [ t ] swap unit-test ;
: must-be-f ( in -- ) [ f ] swap unit-test ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

[       { [ 1 ] [ 2 ] [ 3 ] }          &&  3 = ] must-be-t
[ 3     { [ 0 > ] [ odd? ] [ 2 + ] }    &&  5 = ] must-be-t
[ 10 20 { [ + 0 > ] [ - even? ] [ + ] } && 30 = ] must-be-t

[       { [ 1 ] [ f ] [ 3 ] } &&  3 = ]          must-be-f
[ 3     { [ 0 > ] [ even? ] [ 2 + ] } && ]       must-be-f
[ 10 20 { [ + 0 > ] [ - odd? ] [ + ] } && 30 = ] must-be-f

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

[ { [ 10 0 < ] [ f ] [ "factor" ] } || "factor" = ] must-be-t

[ 10 { [ odd? ] [ 100 > ] [ 1 + ] } || 11 = ]       must-be-t

[ 10 20 { [ + odd? ] [ + 100 > ] [ + ] } || 30 = ]  must-be-t

[ { [ 10 0 < ] [ f ] [ 0 1 = ] } || ] must-be-f

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

