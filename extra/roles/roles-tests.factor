! (c)2009 Joe Groff bsd license
USING: accessors classes.tuple compiler.units kernel qw roles sequences
tools.test ;
IN: roles.tests

ROLE: fork tines ;
ROLE: spoon bowl ;
ROLE: instrument tone ;
ROLE: tuning-fork <{ fork instrument } volume ;

TUPLE: utensil handle ;

! role consumption and tuple inheritance can be mixed
TUPLE: foon <{ utensil fork spoon } ;
TUPLE: tuning-spork <{ utensil spoon tuning-fork } ;

! role class testing
[ t ] [ fork role? ] unit-test
[ f ] [ foon role? ] unit-test

! roles aren't tuple classes by themselves and can't be instantiated
[ f ] [ fork tuple-class? ] unit-test
[ fork new ] must-fail

! tuples which consume roles fall under their class
[ t ] [ foon new fork? ] unit-test
[ t ] [ foon new spoon? ] unit-test
[ f ] [ foon new tuning-fork? ] unit-test
[ f ] [ foon new instrument? ] unit-test

[ t ] [ tuning-spork new fork? ] unit-test
[ t ] [ tuning-spork new spoon? ] unit-test
[ t ] [ tuning-spork new tuning-fork? ] unit-test
[ t ] [ tuning-spork new instrument? ] unit-test

! consumed role slots are placed in tuples in order
[ qw{ handle tines bowl } ] [ foon all-slots [ name>> ] map ] unit-test
[ qw{ handle bowl tines tone volume } ] [ tuning-spork all-slots [ name>> ] map ] unit-test

! can't combine roles whose slots overlap
ROLE: bong bowl ;
SYMBOL: spong

[ [ spong { spoon bong } { } define-tuple-class-with-roles ] with-compilation-unit ]
[ role-slot-overlap? ] must-fail-with 

[ [ spong { spoon bong } { } define-role ] with-compilation-unit ]
[ role-slot-overlap? ] must-fail-with 

! can't try to inherit multiple tuple classes
TUPLE: tool blade ;
SYMBOL: knife

[ knife { utensil tool } { } define-tuple-class-with-roles ]
[ multiple-inheritance-attempted? ] must-fail-with 
