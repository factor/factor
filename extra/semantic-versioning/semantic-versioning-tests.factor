USING: semantic-versioning tools.test ;
IN: semantic-versioning.tests

[ { 1 0 0 "dev1" } ] [ "1.0.0dev1" split-version ] unit-test
[ { 1 2 3 } ] [ "1.2.3" split-version ] unit-test
