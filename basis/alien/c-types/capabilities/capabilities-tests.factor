USING: accessors alien.c-types alien.c-types.capabilities alien.syntax classes.struct cpu.architecture
kernel math tools.test ;
IN: alien.c-types.capabilities.tests

STRUCT: integer-record { value int } ;
STRUCT: float-record { value double } ;
STRUCT: nested-record { values float-record[2] } ;
STRUCT: float-pointer-record { values double* } ;

{ f } [ int base-type contains-floating-point? ] unit-test
{ t } [ double base-type contains-floating-point? ] unit-test
{ f } [ integer-record base-type contains-floating-point? ] unit-test
{ t } [ float-record base-type contains-floating-point? ] unit-test
{ t } [ nested-record base-type contains-floating-point? ] unit-test
{ f } [ float-pointer-record base-type contains-floating-point? ] unit-test

{ t } [ vector-c-type new float-4-rep >>rep contains-floating-point? ] unit-test
{ f } [ vector-c-type new int-4-rep >>rep contains-floating-point? ] unit-test

{ t } [ { void int void* } floating-point-types-supported? ] unit-test
