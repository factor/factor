USING: alien.c-types classes.struct cpu.architecture cpu.m68k.abi
io.files.private io.pathnames kernel namespaces system tools.test words ;
IN: cpu.m68k.abi.tests

STRUCT: m68k-record
    { tag uchar }
    { number uint }
    { value double } ;

cpu m68k? [
    ! getcwd returns char* in A0, including when declared as an encoded string.
    { t } [ cwd absolute-path? ] unit-test
    os netbsd? [
        { 4 8 16 } [
            uint c-type-align double c-type-align m68k-record heap-size
        ] unit-test
    ] [
        { 2 2 14 } [
            uint c-type-align double c-type-align m68k-record heap-size
        ] unit-test
    ] if
] when
{ { { int-regs { } } { float-regs { } } } } [
    f M\ m68k.32 param-regs execute( abi -- regs )
] unit-test
{ { { int-regs { 0 1 } } { float-regs { 0 } } } } [
    M\ m68k.32 return-regs execute( -- regs )
] unit-test
{ t f t } [
    M\ m68k.32 struct-return-register execute( -- reg )
    os netbsd? [ 8 ] [ 9 ] if =
    m68k-record M\ m68k.32 return-struct-in-registers? execute( type -- ? )
    m68k-record M\ m68k.32 value-struct? execute( type -- ? )
] unit-test

{ { { int-regs { 8 } } { float-regs { 0 } } } } [
    void* base-type M\ m68k.32 return-regs-for-type execute( type -- regs )
] unit-test
{ { { int-regs { 0 1 } } { float-regs { 0 } } } } [
    int base-type M\ m68k.32 return-regs-for-type execute( type -- regs )
] unit-test
