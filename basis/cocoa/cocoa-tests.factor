USING: alien.c-types cocoa cocoa.classes cocoa.messages cocoa.runtime
cocoa.subclassing cocoa.types compiler.test core-graphics.types kernel
math memory namespaces tools.test ;
IN: cocoa.tests

<CLASS: Foo < NSObject
    METHOD: void foo: NSRect rect [
        gc rect "x" set
    ] ;
;CLASS>

: test-foo ( -- )
    Foo -> alloc -> init
    dup 1.0 2.0 101.0 102.0 <CGRect> -> foo:
    -> release ;

{ } [ test-foo ] unit-test

{ 1.0 } [ "x" get CGRect-x ] unit-test
{ 2.0 } [ "x" get CGRect-y ] unit-test
{ 101.0 } [ "x" get CGRect-w ] unit-test
{ 102.0 } [ "x" get CGRect-h ] unit-test

<CLASS: Bar < NSObject
    METHOD: NSRect bar [ test-foo "x" get ] ;
;CLASS>

{ } [
    Bar [
        -> alloc -> init
        dup -> bar "x" set
        -> release
    ] compile-call
] unit-test

{ 1.0 } [ "x" get CGRect-x ] unit-test
{ 2.0 } [ "x" get CGRect-y ] unit-test
{ 101.0 } [ "x" get CGRect-w ] unit-test
{ 102.0 } [ "x" get CGRect-h ] unit-test

! Make sure that we can add methods
<CLASS: Bar < NSObject
    METHOD: NSRect bar [ test-foo "x" get ] ;

    METHOD: int babb: int x [ x sq ] ;
;CLASS>

{ 144 } [
    Bar [
        -> alloc -> init
        dup 12 -> babb:
        swap -> release
    ] compile-call
] unit-test

! Redefining a subclass must not replace an inherited implementation.
<CLASS: FactorSubclassAuditParent < NSObject
    METHOD: int subclassAuditValue [ 1 ] ;
;CLASS>

<CLASS: FactorSubclassAuditChild < FactorSubclassAuditParent
;CLASS>

<CLASS: FactorSubclassAuditChild < FactorSubclassAuditParent
    METHOD: int subclassAuditValue [ 2 ] ;
;CLASS>

: subclass-audit-value ( class -- n )
    -> alloc -> init
    dup -> subclassAuditValue swap -> release ;

{ 1 } [ FactorSubclassAuditParent subclass-audit-value ] unit-test
{ 2 } [ FactorSubclassAuditChild subclass-audit-value ] unit-test

<CLASS: FactorSelectorAuditInt < NSObject
    METHOD: int selectorAuditValue [ 3 ] ;
;CLASS>

<CLASS: FactorSelectorAuditDouble < NSObject
    METHOD: double selectorAuditValue [ 4.5 ] ;
;CLASS>

[ "selectorAuditValue" lookup-objc-method ]
[ ambiguous-objc-method? ] must-fail-with

{ { int { id SEL } } }
[ "FactorSelectorAuditInt.selectorAuditValue" lookup-objc-method ] unit-test

{ { double { id SEL } } }
[ "FactorSelectorAuditDouble.selectorAuditValue" lookup-objc-method ] unit-test

{ 3 } [
    FactorSelectorAuditInt -> alloc -> init
    dup -> FactorSelectorAuditInt.selectorAuditValue
    swap -> release
] unit-test

{ 4.5 } [
    FactorSelectorAuditDouble -> alloc -> init
    dup -> FactorSelectorAuditDouble.selectorAuditValue
    swap -> release
] unit-test
