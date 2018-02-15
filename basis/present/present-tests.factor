USING: kernel math present sequences tools.test vocabs
vocabs.hierarchy ;

{ "3" } [ 3 present ] unit-test
{ "Hi" } [ "Hi" present ] unit-test
{ "+" } [ \ + present ] unit-test
{ "kernel" } [ "kernel" lookup-vocab present ] unit-test
{ } [ all-disk-vocabs-recursive filter-vocabs [ present ] map drop ] unit-test

{ "1+1j" } [ C{ 1 1 } present ] unit-test
{ "1-1j" } [ C{ 1 -1 } present ] unit-test
{ "-1+1j" } [ C{ -1 1 } present ] unit-test
{ "-1-1j" } [ C{ -1 -1 } present ] unit-test
