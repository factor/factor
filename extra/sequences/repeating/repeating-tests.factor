USING: sequences.repeating tools.test ;
IN: sequences.repeating.tests

[ { 1 2 3 1 2 } ] [ { 1 2 3 } 5 repeated ] unit-test
[ { 1 2 3 1 2 3 1 2 3 } ] [ { 1 2 3 } 9 repeated ] unit-test
