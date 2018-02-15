USING: kernel tools.test math namespaces prettyprint sequences
inspector io.streams.string ;

[ 1 2 3 ] describe
f describe
\ + describe
H{ } describe
H{ } describe

{ "fixnum\n\n" } [ [ 3 describe ] with-string-writer ] unit-test

{ } [ H{ } clone inspect ] unit-test

{ } [ "a" "b" &add ] unit-test

{ H{ { "b" "a" } } } [ me get ] unit-test

{ } [ "x" 0 &put ] unit-test

{ H{ { "b" "x" } } } [ me get ] unit-test

{ } [ 0 &at ] unit-test

{ "x" } [ me get ] unit-test

{ } [ &back ] unit-test

{ } [ "y" 0 &rename ] unit-test

{ H{ { "y" "x" } } } [ me get ] unit-test

{ } [ 0 &delete ] unit-test

{ H{ } } [ me get ] unit-test
