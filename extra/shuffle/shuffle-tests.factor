USING: arrays shuffle kernel math tools.test inference words ;

[ 8 ] [ 5 6 7 8 3nip ] unit-test
{ 1 2 3 4 1 } [ 1 2 3 4 4 npick ] unit-test
{ 1 2 3 4 2 } [ 1 2 3 4 3 npick ] unit-test
{ 1 2 3 4 3 } [ 1 2 3 4 2 npick ] unit-test
{ 1 2 3 4 4 } [ 1 2 3 4 1 npick ] unit-test
{ t } [ [ 1 1 ndup ] infer >boolean ] unit-test
{ 1 1 } [ 1 1 ndup ] unit-test
{ 1 2 1 2 } [ 1 2 2 ndup ] unit-test
{ 1 2 3 1 2 3 } [ 1 2 3 3 ndup ] unit-test
{ 1 2 3 4 1 2 3 4 } [ 1 2 3 4 4 ndup ] unit-test
{ t } [ [ 1 2 2 nrot ] infer >boolean ] unit-test
{ 2 1 } [ 1 2 2 nrot ] unit-test
{ 2 3 1 } [ 1 2 3 3 nrot ] unit-test
{ 2 3 4 1 } [ 1 2 3 4 4 nrot ] unit-test
{ t } [ [ 1 2 2 -nrot ] infer >boolean ] unit-test
{ 2 1 } [ 1 2 2 -nrot ] unit-test
{ 3 1 2 } [ 1 2 3 3 -nrot ] unit-test
{ 4 1 2 3 } [ 1 2 3 4 4 -nrot ] unit-test
{ t } [ [ 1 2 3 4 3 nnip ] infer >boolean ] unit-test
{ 4 } [ 1 2 3 4 3 nnip ] unit-test
{ t } [ [ 1 2 3 4 4 ndrop ] infer >boolean ] unit-test
{ 0 } [ 0 1 2 3 4 4 ndrop ] unit-test
[ 3 1 2 3 ] [ 1 2 3 tuckd ] unit-test
