USING: alien alien.libraries.finder tools.test ;
IN: alien.libraries.finder

{ f } [ "dont-exist" find-library* ] unit-test
{ "dont-exist" } [ "dont-exist" find-library ] unit-test
