USING: alien.c-types alien.complex alien.syntax classes.struct
compiler.cfg.builder.alien.boxing cpu.architecture cpu.ppc.64le.linux
generic kernel namespaces sequences system tools.test ;
IN: cpu.ppc.64le.linux.tests

STRUCT: ppc64le-pair { a ulonglong } { b ulonglong } ;
STRUCT: ppc64le-triple { a ulonglong } { b ulonglong } { c ulonglong } ;
STRUCT: ppc64le-return-hfa8 { a float[8] } ;
STRUCT: ppc64le-return-hfa9 { a float[9] } ;

: ppc64le-return? ( type -- ? )
    ppc.64le \ return-struct-in-registers? lookup-method execute( type -- ? ) ;

{ t } [ complex-float ppc64le-return? ] unit-test
{ t } [ complex-double ppc64le-return? ] unit-test
{ t } [ ppc64le-pair ppc64le-return? ] unit-test
{ f } [ ppc64le-triple ppc64le-return? ] unit-test
{ t } [ ppc64le-return-hfa8 ppc64le-return? ] unit-test
{ f } [ ppc64le-return-hfa9 ppc64le-return? ] unit-test
{ 8 } [
    [
        0 int-reg-reps set 0 float-reg-reps set
        ppc64le-return-hfa8 ppc.64le \ flatten-struct-type-return lookup-method
        execute( type -- reps ) length
    ] with-scope
] unit-test
