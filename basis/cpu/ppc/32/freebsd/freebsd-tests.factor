USING: accessors alien.c-types alien.complex arrays
compiler.cfg.builder.alien.boxing cpu.architecture cpu.ppc.32.freebsd
generic kernel namespaces sequences system tools.test ;
IN: cpu.ppc.32.freebsd.tests

{ f f } [ complex-double ppc.32 \ value-struct? lookup-method execute( type -- ? )
complex-float ppc.32 \ value-struct? lookup-method execute( type -- ? ) ] unit-test
{ f t } [ complex-double ppc.32 \ return-struct-in-registers? lookup-method execute( type -- ? )
complex-float ppc.32 \ return-struct-in-registers? lookup-method execute( type -- ? ) ] unit-test
{ { { int-rep f f } { int-rep f f } } } [ 0 int-reg-reps set 0 float-reg-reps set complex-float ppc.32 \ flatten-struct-type-return lookup-method execute( type -- reps ) >array ] unit-test

{ { 0 } { 3 } } [ 3 ppc32-return-components [ >array ] dip [ size>> ] map ] unit-test
{ { 0 1 } { 1 f } } [ 5 ppc32-return-components [ >array ] dip [ dup [ size>> ] when ] map ] unit-test
{ { 0 4 } { f f } } [ 8 ppc32-return-components [ >array ] dip ] unit-test
