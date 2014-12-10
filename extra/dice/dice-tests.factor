USING: math random tools.test ;
IN: dice

{ [ 0 1 [ 4 random + 1 + ] times ] } [ "1d4" parse-roll ] unit-test
{ [ 0 15 [ 45 random + 1 + ] times ] } [ "15d45" parse-roll ] unit-test
