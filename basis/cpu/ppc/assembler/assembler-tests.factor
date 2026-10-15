USING: cpu.ppc.assembler kernel make namespaces tools.test ;
FROM: cpu.ppc.assembler => B ;
IN: cpu.ppc.assembler.tests

! Signed displacements must not overwrite the opcode, BO or BI fields.
{ B{ 0x4b 0xff 0xff 0xe8 } } [
    [ f ppc-little-endian set [ -24 B ] B{ } make ] with-scope
] unit-test
{ B{ 0x4b 0xff 0xff 0xe9 } } [
    [ f ppc-little-endian set [ -24 BL ] B{ } make ] with-scope
] unit-test
{ B{ 0x41 0x80 0xff 0xe8 } } [
    [ f ppc-little-endian set [ 0 -24 BLT ] B{ } make ] with-scope
] unit-test
{ B{ 0x48 0x00 0x00 0x18 } } [
    [ f ppc-little-endian set [ 24 B ] B{ } make ] with-scope
] unit-test
{ B{ 0xe8 0xff 0xff 0x4b } } [
    [ t ppc-little-endian set [ -24 B ] B{ } make ] with-scope
] unit-test
{ B{ 0xe8 0xff 0x80 0x41 } } [
    [ t ppc-little-endian set [ 0 -24 BLT ] B{ } make ] with-scope
] unit-test
