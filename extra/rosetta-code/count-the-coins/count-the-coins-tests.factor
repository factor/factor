
USING: tools.test ;

IN: rosetta-code.count-the-coins

{ 242 } [ 100 { 25 10 5 1 } make-change ] unit-test
{ 13398445413854501 } [ 100000 { 100 50 25 10 5 1 } make-change ] unit-test
