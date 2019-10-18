USING: kernel math tools.test units.imperial ;
IN: temporary

[ 1 ] [ 12 inches [ feet ] undo ] unit-test
[ 12 ] [ 1 feet [ inches ] undo ] unit-test

[ t ] [ 16 ounces 1 pounds = ] unit-test
[ t ] [ 1 pounds [ ounces ] undo 16 = ] unit-test

[ 1 ] [ 4 quarts [ gallons ] undo ] unit-test
[ 4 ] [ 1 gallons [ quarts ] undo ] unit-test

[ 2 ] [ 1 pints [ cups ] undo ] unit-test
[ 1 ] [ 2 cups [ pints ] undo ] unit-test

[ 256 ] [ 1 gallons [ tablespoons ] undo ] unit-test
[ 1 ] [ 256 tablespoons [ gallons ] undo ] unit-test

[ 768 ] [ 1 gallons [ teaspoons ] undo ] unit-test
[ 1 ] [ 768 teaspoons [ gallons ] undo ] unit-test

