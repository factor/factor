
USING: tools.test ;

IN: rosetta-code.raycasting

CONSTANT: square { { -2 -1 } { 1 -2 } { 2 1 } { -1 2 } }

{ t } [ square { 0 0 } raycast ] unit-test
{ f } [ square { 5 5 } raycast ] unit-test
{ f } [ square { 2 0 } raycast ] unit-test
