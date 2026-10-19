USING: alien.c-types alien.c-types.private classes.struct cpu.architecture cpu.vax.abi kernel
system tools.test words ;
IN: cpu.vax.abi.tests

STRUCT: vax-one-byte { value uchar } ;
STRUCT: vax-two-words { first uint } { second uint } ;
{ { { int-regs { } } { float-regs { } } } }
[ f M\ vax.32 param-regs execute( abi -- regs ) ] unit-test
{ { { int-regs { 0 1 } } { float-regs { 0 } } } }
[ M\ vax.32 return-regs execute( -- regs ) ] unit-test
{ f f 1 t }
[ vax-one-byte M\ vax.32 return-struct-in-registers? execute( type -- ? )
  vax-two-words M\ vax.32 return-struct-in-registers? execute( type -- ? )
  M\ vax.32 struct-return-register execute( -- reg )
  M\ vax.32 return-struct-pointer? execute( -- ? ) ] unit-test

! Native GNU VAX limits scalar/field alignment to32 bits; IEEE boxed-float
! image alignment remains a separate VM layout contract.
{ 4 4 8 8 }
[ vax.32 netbsd 8-byte-alignment-for
  x86.32 netbsd 8-byte-alignment-for
  x86.32 windows 8-byte-alignment-for
  x86.64 netbsd 8-byte-alignment-for ] unit-test
