USING: alien alien.libraries.finder tools.test ;
IN: alien.libraries.finder.tests

[ f ] [ "dont-exist" find-library ] unit-test
