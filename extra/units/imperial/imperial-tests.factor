USING: kernel math tools.test units.imperial inverse ;

{ 1 } [ 12 inches [ feet ] undo ] unit-test
{ 12 } [ 1 feet [ inches ] undo ] unit-test

{ t } [ 16 ounces 1 pounds = ] unit-test
{ t } [ 1 pounds [ ounces ] undo 16 = ] unit-test

{ 1 } [ 4 quarts [ gallons ] undo ] unit-test
{ 4 } [ 1 gallons [ quarts ] undo ] unit-test

{ 2 } [ 1 pints [ cups ] undo ] unit-test
{ 1 } [ 2 cups [ pints ] undo ] unit-test

{ 256 } [ 1 gallons [ tablespoons ] undo ] unit-test
{ 1 } [ 256 tablespoons [ gallons ] undo ] unit-test

{ 768 } [ 1 gallons [ teaspoons ] undo ] unit-test
{ 1 } [ 768 teaspoons [ gallons ] undo ] unit-test

{ 1 } [ 6 feet [ fathoms ] undo ] unit-test
{ 1 } [ 8 furlongs [ miles ] undo ] unit-test
{ 1 } [ 100 links [ chains ] undo ] unit-test
{ 1 } [ 40 poles [ furlongs ] undo ] unit-test
{ 1 } [ 100 feet [ ramsdens-chains ] undo ] unit-test

{ 1 } [ 15 fathoms [ shackles ] undo ] unit-test
{ 1 } [ 30 yards [ shackles ] undo ] unit-test
{ 1 } [ 608 feet [ cables ] undo ] unit-test

{ 1 } [ 4 inches [ hands ] undo ] unit-test
{ 1 } [ 3 inches [ palms ] undo ] unit-test
{ 1 } [ 16 nails [ yards ] undo ] unit-test
{ 7 } [ 8 fingers [ inches ] undo ] unit-test
