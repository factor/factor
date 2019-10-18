USING: case kernel test ;

[ "Hello How Are You?" ] [ "hEllo how ARE yOU?" u>title ] unit-test
[ "FUSS" ] [ "Fu\u00DF" u>upper ] unit-test
[ "\u03C3\u03C2" ] [ "\u03A3\u03A3" u>lower ] unit-test
[ t ] [ "hello how are you?" lower? ] unit-test

[ "ab\u064b\u034d\u034e\u0347\u0346" ] [ "ab\u0346\u0347\u064b\u034e\u034d" reorder ] unit-test
[ "hello" "hello" ] [ "hello" [ nfd ] keep nfkd ] unit-test
[ "\uFB012\u2075\u017F\u0323\u0307" "fi25s\u0323\u0307" ]
[ "\uFB012\u2075\u1E9B\u0323" [ nfd ] keep nfkd ] unit-test
