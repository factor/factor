USING: kernel math.constants math.continued-fractions tools.test ;

{ V{ 2 2.0 } } [ V{ 2.5 } dup next-approx ] unit-test
{ V{ 2 2 } } [ V{ 2.5 } dup next-approx dup next-approx ] unit-test

{ 5/2 } [ V{ 2 2.1 } >ratio ] unit-test
{ 5/2 } [ V{ 2 1.9 } >ratio ] unit-test
{ 5/2 } [ V{ 2 2.0 } >ratio ] unit-test
{ 5/2 } [ V{ 2 2 } >ratio ] unit-test

{ 3 } [ 1 pi approx ] unit-test
{ 22/7 } [ 0.1 pi approx ] unit-test
{ 355/113 } [ 0.00001 pi approx ] unit-test

{ 2 } [ 1 2 approx ] unit-test
{ 2 } [ 0.1 2 approx ] unit-test
{ 2 } [ 0.00001 2 approx ] unit-test

{ 3 } [ 1 2.5 approx ] unit-test
{ 5/2 } [ 0.1 2.5 approx ] unit-test
{ 5/2 } [ 0.0001 2.5 approx ] unit-test
