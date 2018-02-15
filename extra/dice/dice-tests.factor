USING: dice kernel math tools.test ;

{ [ 1 4 random-roll ] } [ "1d4" roll-quot ] unit-test
{ [ 1 4 random-roll 3 + ] } [ "1d4+3" roll-quot ] unit-test
{ [ 15 45 random-roll ] } [ "15d45" roll-quot ] unit-test
