USING: alien.c-types alien.syntax classes.struct cpu.ppc.64le.abi
kernel sequences tools.test ;
IN: cpu.ppc.64le.abi.tests

STRUCT: ppc64le-hfa8 { values float[8] } ;
STRUCT: ppc64le-hfa9 { values float[9] } ;
STRUCT: ppc64le-padded { x float } { y double } ;
STRUCT: ppc64le-inner { x double } { y double } ;
STRUCT: ppc64le-nested { values ppc64le-inner[4] } ;
UNION-STRUCT: ppc64le-hfa-union { one double } { two double[2] } ;

{ 8 } [ ppc64le-hfa8 lookup-c-type ppc64le-hfa-members length ] unit-test
{ f } [ ppc64le-hfa9 lookup-c-type ppc64le-hfa-members ] unit-test
{ f } [ ppc64le-padded lookup-c-type ppc64le-hfa-members ] unit-test
{ 8 } [ ppc64le-nested lookup-c-type ppc64le-hfa-members length ] unit-test
{ 2 } [ ppc64le-hfa-union lookup-c-type ppc64le-hfa-members length ] unit-test
