USING: arrays shuffle kernel math tools.test compiler words ;

[ 8 ] [ 5 6 7 8 3nip ] unit-test
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
{ t } [ [ 1 2 3 4 3 nnip ] compile-quot compiled? ] unit-test
{ 4 } [ 1 2 3 4 3 nnip ] unit-test
{ t } [ [ 1 2 3 4 4 ndrop ] compile-quot compiled? ] unit-test
{ 0 } [ 0 1 2 3 4 4 ndrop ] unit-test
[ 3 1 2 3 ] [ 1 2 3 tuckd ] unit-test
