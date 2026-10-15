USING: compiler.codegen.relocation cpu.sh.assembler cpu.sh.codegen
kernel make namespaces sequences tools.test ;
IN: cpu.sh.codegen.tests
: code ( quot -- bytes ) [ init-relocation call ] B{ } make ; inline
! Both starting alignments must place an inline cell at a four-byte boundary.
{ B{ 1 208 3 160 9 0 9 0 239 205 171 137 } }
[ [ 0 0x89abcdef literal ] code ] unit-test
{ B{ 9 0 9 0 1 208 3 160 9 0 9 0 239 205 171 137 } }
[ [ NOP 0 0x89abcdef literal ] code ] unit-test
{ B{ 2 208 11 64 9 0 3 160 9 0 9 0 0 0 0 0 } }
[ [ CALL ] code ] unit-test
{ B{ 2 208 43 64 9 0 3 160 9 0 9 0 0 0 0 0 } }
[ [ JUMP ] code ] unit-test
{ B{ 51 97 35 99 24 51 } }
[ [ 3 2 3 [ SUB ] binary-op ] code ] unit-test
{ B{ 0x1a 0x40 0x0a 0x40 } }
[ [ 0 LDS-MACL 0 LDS-MACH ] code ] unit-test
! Restoring PR must preserve both integer callback return registers.
{ B{ 0xf1 0x57 0x2a 0x47 0xf0 0x5e 0x10 0x7f } }
[ [ linked-epilog ] code ] unit-test
