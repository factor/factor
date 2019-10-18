USING: combinators.short-circuit.smart kernel math tools.test ;

{ t } [       { [ 1 ] [ 2 ] [ 3 ] }          &&  3 = ] unit-test
{ t } [ 3     { [ 0 > ] [ odd? ] [ 2 + ] }    &&  5 = ] unit-test
{ t } [ 10 20 { [ + 0 > ] [ - even? ] [ + ] } && 30 = ] unit-test

{ f } [       { [ 1 ] [ f ] [ 3 ] } &&  3 = ]          unit-test
{ f } [ 3     { [ 0 > ] [ even? ] [ 2 + ] } && ]       unit-test
{ f } [ 10 20 { [ + 0 > ] [ - odd? ] [ + ] } && 30 = ] unit-test

{ t } [ { [ 10 0 < ] [ f ] [ "factor" ] } || "factor" = ] unit-test

{ t } [ 10 { [ odd? ] [ 100 > ] [ 1 + ] } || 11 = ]       unit-test

{ t } [ 10 20 { [ + odd? ] [ + 100 > ] [ + ] } || 30 = ]  unit-test

{ f } [ { [ 10 0 < ] [ f ] [ 0 1 = ] } || ] unit-test
