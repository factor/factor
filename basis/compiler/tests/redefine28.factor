USING: accessors classes.mixin compiler.units kernel math slots
tools.test ;
IN: compiler.tests.redefine28

! #1751: branch constraints must not replace the assumption that caused
! the predicate to fold, including the check in a tuple constructor.
MIXIN: changing-member
TUPLE: checked-holder { value maybe{ changing-member } } ;

: construct-holder ( value -- holder ) checked-holder boa ;
: store-holder ( value -- holder ) checked-holder new swap >>value ;
: literal-holder ( -- holder ) 3 checked-holder boa ;
: checked-member? ( value -- ? )
    dup [ changing-member? ] [ drop t ] if ;
: literal-member? ( -- ? ) 3 changing-member? ;

{ f } [ f construct-holder value>> ] unit-test
{ f } [ f store-holder value>> ] unit-test
{ t f f } [ f checked-member? 3 checked-member? literal-member? ] unit-test
[ 3 construct-holder ] [ bad-slot-value? ] must-fail-with
[ 3 store-holder ] [ bad-slot-value? ] must-fail-with
[ literal-holder ] [ bad-slot-value? ] must-fail-with

{ } [ [ fixnum changing-member add-mixin-instance ] with-compilation-unit ] unit-test

{ 3 } [ 3 construct-holder value>> ] unit-test
{ 3 } [ 3 store-holder value>> ] unit-test
{ 3 } [ literal-holder value>> ] unit-test
{ t t t f } [ f checked-member? 3 checked-member? literal-member? 3.0 checked-member? ] unit-test
[ 3.0 construct-holder ] [ bad-slot-value? ] must-fail-with
[ 3.0 store-holder ] [ bad-slot-value? ] must-fail-with

{ } [ [ float changing-member add-mixin-instance ] with-compilation-unit ] unit-test
{ 3.0 } [ 3.0 construct-holder value>> ] unit-test
{ t } [ 3.0 checked-member? ] unit-test

{ } [ [ fixnum changing-member remove-mixin-instance ] with-compilation-unit ] unit-test

{ f } [ f construct-holder value>> ] unit-test
{ 3.0 } [ 3.0 construct-holder value>> ] unit-test
{ t f f t } [ f checked-member? 3 checked-member? literal-member? 3.0 checked-member? ] unit-test
[ 3 construct-holder ] [ bad-slot-value? ] must-fail-with
[ 3 store-holder ] [ bad-slot-value? ] must-fail-with
[ literal-holder ] [ bad-slot-value? ] must-fail-with

{ } [ [ float changing-member remove-mixin-instance ] with-compilation-unit ] unit-test
{ f } [ f construct-holder value>> ] unit-test
{ t f f f } [ f checked-member? 3 checked-member? literal-member? 3.0 checked-member? ] unit-test
[ 3.0 construct-holder ] [ bad-slot-value? ] must-fail-with
