USING: math.order semantic-versioning tools.test ;
IN: semantic-versioning.tests

[ { 1 0 0 "dev1" } ] [ "1.0.0dev1" split-version ] unit-test
[ { 1 2 3 } ] [ "1.2.3" split-version ] unit-test

[ +gt+ ] [ "1.2.0dev1" "0.12.1dev2" version<=> ] unit-test
[ +eq+ ] [ "2.0.0rc1" "2.0.0rc1" version<=> ] unit-test
[ +lt+ ] [ "1.0.0rc1" "1.0.0" version<=> ] unit-test
[ +lt+ ] [ "1.0.0rc1" "1.0.0rc2" version<=> ] unit-test