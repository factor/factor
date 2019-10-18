USING: shuffle kernel math test compiler words ;

[ { 910 911 912 } ] [ 10 900 3 [ + + ] map-with2 ] unit-test
[ 8 ] [ 5 6 7 8 3nip ] unit-test
{ 6 2 } [ 1 2 [ 5 + ] dip ] unit-test
{ 6 2 1 } [ 1 2 1 [ 5 + ] dipd ] unit-test
{ 1 2 3 4 1 } [ 1 2 3 4 4 npick ] unit-test
{ 1 2 3 4 2 } [ 1 2 3 4 3 npick ] unit-test
{ 1 2 3 4 3 } [ 1 2 3 4 2 npick ] unit-test
{ 1 2 3 4 4 } [ 1 2 3 4 1 npick ] unit-test
{ t } [ [ 1 1 ndup ] compile-quot compiled? ] unit-test
{ 1 1 } [ 1 1 ndup ] unit-test
{ 1 2 1 2 } [ 1 2 2 ndup ] unit-test
{ 1 2 3 1 2 3 } [ 1 2 3 3 ndup ] unit-test
{ 1 2 3 4 1 2 3 4 } [ 1 2 3 4 4 ndup ] unit-test
{ t } [ [ 1 2 2 nrot ] compile-quot compiled? ] unit-test
{ 2 1 } [ 1 2 2 nrot ] unit-test
{ 2 3 1 } [ 1 2 3 3 nrot ] unit-test
{ 2 3 4 1 } [ 1 2 3 4 4 nrot ] unit-test
{ t } [ [ 1 2 2 -nrot ] compile-quot compiled? ] unit-test
{ 2 1 } [ 1 2 2 -nrot ] unit-test
{ 3 1 2 } [ 1 2 3 3 -nrot ] unit-test
{ 4 1 2 3 } [ 1 2 3 4 4 -nrot ] unit-test
{ t } [ [ [ 99 ] 1 2 3 4 5 5 nslip ] compile-quot compiled? ] unit-test
{ 99 1 2 3 4 5 } [ [ 99 ] 1 2 3 4 5 5 nslip ] unit-test
{ t } [ [ 1 2 3 4 5 [ drop drop drop drop drop 2 ] 5 nkeep ] compile-quot compiled? ] unit-test
{ 2 1 2 3 4 5 } [ 1 2 3 4 5 [ drop drop drop drop drop 2 ] 5 nkeep ] unit-test
{ t } [ [ 1 2 { 3 4 } [ + + ] 2 map-withn ] compile-quot compiled? ] unit-test
{ { 6 7 } } [ 1 2 { 3 4 } [ + + ] 2 map-withn ] unit-test
{ { 16 17 18 19 20 } } [ 1 2 3 4 { 6 7 8 9 10 } [ + + + + ] 4 map-withn ] unit-test
{ t } [ [ 1 2 3 4 3 nnip ] compile-quot compiled? ] unit-test
{ 4 } [ 1 2 3 4 3 nnip ] unit-test
{ t } [ [ 1 2 { 3 4 } [ + + drop ] 2 each-withn  ] compile-quot compiled? ] unit-test
{ 13 } [ 1 2 { 3 4 } [ + + ] 2 each-withn + ] unit-test
{ t } [ [ 1 2 3 4 4 ndrop ] compile-quot compiled? ] unit-test
{ 0 } [ 0 1 2 3 4 4 ndrop ] unit-test
