USING: accessors alien.c-types alien.complex alien.syntax arrays classes.struct
compiler.cfg.builder.alien.boxing cpu.architecture cpu.ppc
cpu.ppc.32.netbsd cpu.ppc.32.svr4 generic kernel namespaces
sequences system tools.test ;
IN: cpu.ppc.32.netbsd.tests

STRUCT: netbsd-return-eight { bytes uchar[8] } ;
STRUCT: netbsd-return-nine { bytes uchar[9] } ;

! NetBSD GCC retains GNU complex argument classification.
{ t t } [ complex-double ppc \ value-struct? lookup-method execute( type -- ? )
complex-float ppc \ value-struct? lookup-method execute( type -- ? ) ] unit-test
{ t t } [ complex-double ppc.32 \ return-struct-in-registers? lookup-method execute( type -- ? )
complex-float ppc.32 \ return-struct-in-registers? lookup-method execute( type -- ? ) ] unit-test
{ { { int-rep f f } { int-rep f f } } } [ 0 int-reg-reps set 0 float-reg-reps set complex-float ppc.32 \ flatten-struct-type-return lookup-method execute( type -- reps ) >array ] unit-test

! The complex-double exception must not admit ordinary nine-byte aggregates.
{ t f } [ netbsd-return-eight ppc.32 \ return-struct-in-registers? lookup-method execute( type -- ? )
netbsd-return-nine ppc.32 \ return-struct-in-registers? lookup-method execute( type -- ? ) ] unit-test
{ { { int-rep f f } { int-rep f f } { int-rep f f } { int-rep f f } } } [ 0 int-reg-reps set 0 float-reg-reps set complex-double ppc.32 \ flatten-struct-type-return lookup-method execute( type -- reps ) >array ] unit-test

! Odd byte counts occupy the low end of the complete r3/r4 integer value.
{ { 0 } { 1 } } [ 1 ppc32-return-components [ >array ] dip [ size>> ] map ] unit-test
{ { 0 } { 3 } } [ 3 ppc32-return-components [ >array ] dip [ size>> ] map ] unit-test
{ { 0 1 } { 1 f } } [ 5 ppc32-return-components [ >array ] dip [ dup [ size>> ] when ] map ] unit-test
{ { 0 3 } { 3 f } } [ 7 ppc32-return-components [ >array ] dip [ dup [ size>> ] when ] map ] unit-test
{ { 0 4 } { f f } } [ 8 ppc32-return-components [ >array ] dip ] unit-test
