USING: make sequences tools.test ;

{ "ABCD" } [ [ "ABCD" [ , ] each ] "" make ] unit-test

{ H{ { "key" "value" } } }
[ [ "value" "key" ,, ] H{ } make ] unit-test

{ { { 1 2 } } } [ [ 2 1 ,, ] { } make ] unit-test
